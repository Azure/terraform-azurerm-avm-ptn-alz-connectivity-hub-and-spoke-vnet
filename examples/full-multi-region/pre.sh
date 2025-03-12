echo "Running pre.sh script..."
echo "Downloading the terraform.tfvars file for the hub-and-spoke-vnet example..."
curl -o terraform.tfvars https://raw.githubusercontent.com/Azure/alz-terraform-accelerator/refs/heads/main/templates/platform_landing_zone/examples/full-multi-region/hub-and-spoke-vnet.tfvars
echo "File downloaded successfully."
echo "Finished running pre.sh script."