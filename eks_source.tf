# Create a temporary directory to store the YAML files
resource "null_resource" "sync_manifests" {
  triggers = {
    s3_bucket = var.s3_bucket_name
    # Add a timestamp to force execution every time
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    # Create temp directory, sync S3 files, apply them, then cleanup
    command = <<-EOT
      # Configure kubectl
      aws eks --region ${var.aws_region} update-kubeconfig --name ${var.cluster_name}
      
      # Create temp directory
      TEMP_DIR=$(mktemp -d)
      
      # Sync files from S3
      aws s3 sync s3://${var.s3_bucket_name}/ $TEMP_DIR/
      
      # Wait for cluster to be ready
      until kubectl get nodes &> /dev/null; do echo "Waiting for cluster..."; sleep 5; done
      
      # Apply ConfigMaps first
      if [ -d "$TEMP_DIR/configmaps" ]; then
        echo "Applying ConfigMaps..."
        kubectl apply -f $TEMP_DIR/configmaps/
      fi
      
      # Apply Secrets second
      if [ -d "$TEMP_DIR/secrets" ]; then
        echo "Applying Secrets..."
        kubectl apply -f $TEMP_DIR/secrets/
      fi
      
      # Apply Services third
      if [ -d "$TEMP_DIR/services" ]; then
        echo "Applying Services..."
        kubectl apply -f $TEMP_DIR/services/
      fi
      
      # Apply Deployments fourth
      if [ -d "$TEMP_DIR/deployment" ]; then
        echo "Applying Deployments..."
        kubectl apply -f $TEMP_DIR/deployment/
      fi
      
      # Apply Ingress fifth
      if [ -d "$TEMP_DIR/ingress" ]; then
        echo "Applying Ingress..."
        kubectl apply -f $TEMP_DIR/ingress/
      fi
      
      # Apply CronJobs last
      if [ -d "$TEMP_DIR/crons" ]; then
        echo "Applying CronJobs..."
        kubectl apply -f $TEMP_DIR/crons/
      fi
      
      # Cleanup
      rm -rf $TEMP_DIR
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }

  depends_on = [module.eks]
}

# Optional: Add a way to verify the deployment status
resource "null_resource" "verify_deployment" {
  triggers = {
    sync_id = null_resource.sync_manifests.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for deployments to be ready
      kubectl get deployments -A
      kubectl get pods -A
    EOT
  }

  depends_on = [null_resource.sync_manifests]
}