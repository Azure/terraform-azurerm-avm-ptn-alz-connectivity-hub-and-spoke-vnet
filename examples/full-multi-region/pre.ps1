Write-Output "Downloading and creating the test.auto.tfvars file from https://raw.githubusercontent.com/Azure/alz-terraform-accelerator/refs/heads/main/templates/platform_landing_zone/examples/full-multi-region/hub-and-spoke-vnet.tfvars..."
# Invoke-WebRequest -OutFile test.auto.tfvars https://raw.githubusercontent.com/Azure/alz-terraform-accelerator/refs/heads/main/templates/platform_landing_zone/examples/full-multi-region/hub-and-spoke-vnet.tfvars
Write-Output "File downloaded successfully."
Write-Output "Adding randomness to the resource group names..."
$randomness = [System.Guid]::NewGuid().ToString("N").Substring(0, 4)
(Get-Content test.auto.tfvars) -replace "rg-", "rg-$randomness-" | Set-Content test.auto.tfvars
Write-Output "Randomness added to the resource group names."
