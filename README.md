# Cloud Minecraft Server (Terraform & OCI)

A fully automated, "out-of-the-box" Minecraft server deployment on Oracle Cloud Infrastructure (OCI) using Terraform.

## 🚀 Features
*   **Zero-Cost Capable**: Optimized for OCI "Always Free" Arm instances.
*   **One-Click Deploy**: Automated PowerShell script handles infrastructure-as-code.
*   **Auto-Configured**: Sets up Java, Fabric (default) or PaperMC, Firewalls, and System Services automatically.
*   **Management API**: Includes a lightweight HTTP API to Start/Stop the server remotely.
*   **Mod Support**: Automatically uploads and installs mods from a local folder.

## 📂 Project Structure
*   `easy_deploy.ps1`: The main automation script.
*   `steps.md`: **Detailed setup guide.** READ THIS FIRST!
*   `infrastructure/`: Contains Terraform code configuration.
*   `server_mods/`: (Optional) folder for your .jar mods.

## ⚡ Quick Start

### 1. Configure Credentials
You need your OCI API Keys and OCIDs.
1.  Place your OCI Private Key in `infrastructure/ter_keys/private_ter.pem`.
2.  Update `infrastructure/terraform.tfvars` with your `tenancy_ocid`, `user_ocid`, `fingerprint`, and `region`.

> **Need help finding these?**  
> See [steps.md](steps.md) for a step-by-step walkthrough.

### 2. Deploy
Run the automation script in PowerShell:

```powershell
    PowerShell -ExecutionPolicy Bypass -File .\easy_deploy.ps1
```

This will:
1.  Check/Generate SSH keys for the server.
2.  Provision VCN, Subnets, and Firewall rules.
3.  Create the VM and install Minecraft (Fabric by default, or PaperMC).
4.  Upload any mods found in `server_mods/`.
5.  Wait for the server to be ready.

### 3. Play
*   **Connect**: Use the IP Address displayed at the end of the script.
*   **Manage**: Use the provided `Invoke-RestMethod` commands to Start/Stop the server via the API (Port 8080).

## 🛠️ Customization
Edit `infrastructure/terraform.tfvars` to change:
*   **Hardware**: `vm_ocpus` (Default: 1), `vm_memory_gbs` (Default: 6)
*   **Game**: `mc_server_type`, `mc_version` (default "1.21.11"), `mc_gamemode`, `mc_difficulty`, `mc_level_seed`, `mc_online_mode`

## ❓ Troubleshooting
*   **401 Authentication Error**: Double check your API Key Fingerprint and User OCID in `terraform.tfvars`.
*   **Server Offline but Deployed**: SSH into the server and check `/home/ubuntu/minecraft/logs/latest.log`.
    *   *Common Cause*: Mod version mismatch (e.g. Mod requires MC 1.21.11 but server is 1.21.1). Fix via `mc_version` variable.

## ⚠️ Destruction
To delete all resources and stop potential billing:

```powershell
cd infrastructure
terraform destroy -auto-approve
```
