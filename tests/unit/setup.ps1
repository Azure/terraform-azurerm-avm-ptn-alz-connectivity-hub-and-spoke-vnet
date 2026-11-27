#requires -Version 7.4
$ErrorActionPreference = 'Stop'
$repositoryPath = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$sourcePath = Join-Path $repositoryPath 'examples/full-multi-region/locals.shared_keys.tf'
$targetPath = Join-Path $PSScriptRoot 'fixtures/shared_keys/template/locals.shared_keys.tf'
Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
if ((Get-FileHash -LiteralPath $sourcePath).Hash -ne (Get-FileHash -LiteralPath $targetPath).Hash) {
    throw 'The template regression must load the exact production adapter.'
}
if ($IsWindows) {
    $null = [IO.Directory]::CreateDirectory((Join-Path $repositoryPath '.terraform/modules/test.tests/unit'))
}