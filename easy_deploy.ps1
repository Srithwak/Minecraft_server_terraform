<#
.SYNOPSIS
    One-click deployment script for Cloud Minecraft Server.
.DESCRIPTION
    1. Checks for SSH keys and generates them if missing.
    2. Checks for OCI API keys.
    3. Initializes and Applies Terraform.
    4. Waits for the server to come online.
#>

$ErrorActionPreference = "Stop"
$InfraDir = Join-Path $PSScriptRoot "infrastructure"
$KeyDir = Join-Path $InfraDir "ter_keys"

Write-Host "[*] Starting Cloud Minecraft Deployment..." -ForegroundColor Cyan

try {
    # 1. Check Prerequisites
    if (!(Get-Command terraform -ErrorAction SilentlyContinue)) {
        Throw "Terraform is not installed or not in PATH. Please install Terraform."
    }

    # 2. Check OCI Keys
    if (!(Test-Path "$KeyDir\private_ter.pem")) {
        Write-Warning "Missing OCI API Key: $KeyDir\private_ter.pem"
        Write-Host "Please paste your OCI Private API Key content into 'infrastructure/ter_keys/private_ter.pem' before proceeding." -ForegroundColor Yellow
        Throw "Missing OCI Private Key"
    }

    # 3. SSH Key Automation
    # Handled by Terraform automatically!

    # 4. Terraform Execution
    Set-Location $InfraDir

    Write-Host "[TF] Initializing Terraform..." -ForegroundColor Green
    terraform init -upgrade

    Write-Host "[TF] Applying Infrastructure (This may take 2-5 minutes)..." -ForegroundColor Green
    terraform apply -auto-approve

    # 5. Get Connection Info
    $PublicIP = terraform output -raw public_ip
    if ([string]::IsNullOrWhiteSpace($PublicIP)) {
        Throw "Failed to get Public IP from Terraform."
    }

    Write-Host "[OK] Server Deployed at IP: $PublicIP" -ForegroundColor Green
    Write-Host "[wait] Waiting for Minecraft API (Port 8080) to initialize..." -ForegroundColor Yellow

    # 6. Wait for Service
    $RetryCount = 0
    $MaxRetries = 120 # 10 minutes (5s * 120)
    $ServerReady = $false

    Write-Host "   Waiting 30s for VM to boot..." -ForegroundColor DarkGray
    Start-Sleep -Seconds 30

    while ($RetryCount -lt $MaxRetries) {
        try {
            $Response = Invoke-RestMethod -Uri "http://${PublicIP}:8080/status" -ErrorAction Stop -TimeoutSec 2
            $ServerReady = $true
            break
        } catch {
            Write-Host "   [$RetryCount/$MaxRetries] Server initializing... (Retrying in 5s)" -ForegroundColor DarkGray
            Start-Sleep -Seconds 5
            $RetryCount++
        }
    }

    if ($ServerReady) {
        Write-Host "`n[SUCCESS] SERVER ONLINE!" -ForegroundColor Green
        Write-Host "---------------------------------------------------"
        Write-Host "Start Server:  Invoke-RestMethod -Method Post -Uri ""http://${PublicIP}:8080/start""" -ForegroundColor Cyan
        Write-Host "Check Status:  Invoke-RestMethod -Uri ""http://${PublicIP}:8080/status""" -ForegroundColor Cyan
        Write-Host "Stop Server:   Invoke-RestMethod -Method Post -Uri ""http://${PublicIP}:8080/stop""" -ForegroundColor Cyan
        Write-Host "---------------------------------------------------"
    } else {
        Throw "Server deployed, but API did not respond within 5 minutes. Check SSH logs."
    }

} catch {
    Write-Error "An error occurred: $_"
    Write-Host "Detailed Error trace:`n$($_.ScriptStackTrace)" -ForegroundColor Red
} finally {
    # Return to script root
    Set-Location $PSScriptRoot
    Write-Host "`nPress Enter to exit..." -ForegroundColor Cyan
    Read-Host
}
