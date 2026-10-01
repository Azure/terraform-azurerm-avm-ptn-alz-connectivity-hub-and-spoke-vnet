#!/usr/bin/env pwsh
# Adds randomness to the resource group names in test.auto.tfvars.
# Source of test.auto.tfvars: https://raw.githubusercontent.com/Azure/alz-terraform-accelerator/refs/heads/main/templates/platform_landing_zone/examples/full-multi-region/hub-and-spoke-vnet.tfvars

Set-StrictMode -Version 3.0
$ErrorActionPreference = 'Stop'

$tfvarsPath = Join-Path $PSScriptRoot 'test.auto.tfvars'
$randomness = '{0:x4}' -f (Get-Random -Minimum 0 -Maximum 0x10000)

$content = [System.IO.File]::ReadAllText($tfvarsPath)
[System.IO.File]::WriteAllText($tfvarsPath, $content.Replace('rg-', "rg-$randomness-"))

Write-Host "Added randomness '$randomness' to the resource group names."
