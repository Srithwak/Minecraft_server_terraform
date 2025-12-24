# Detailed Setup Guide

Follow these steps to deploy your Minecraft server on Oracle Cloud Infrastructure (OCI) using Terraform.

## 1. Prerequisites
*   **Oracle Cloud Account**: A generic "Always Free" account works perfectly.
*   **Terraform**: Download and install from [terraform.io](https://www.terraform.io/downloads).
*   **Git**: Recommended for managing the code.

## 2. Oracle Cloud Setup (One-Time)
1.  **Login** to your OCI Console.
2.  **User Settings**: Click the **Profile Icon** (top right) -> **My Profile**.
3.  **API Keys**:
    *   Click **User Settings**.
    *   Click **Token and Keys**.
    *   Click **Add API Key**.
    *   Select **Generate API Key Pair**.
    *   **Download Private Key**: Save this file! You will need it.
    *   Click **Add**.
4.  **Copy Configuration**:
    *   Success message will show a "Configuration File Preview".
    *   Save the values for: `user`, `fingerprint`, `tenancy`, `region`, and `compartment_id`.

## 3. Project Configuration
1.  **API Key Setup**:
    *   Go to the `infrastructure/ter_keys/` folder in this project.
    *   Move your downloaded private key (e.g., `oracleidentitycloudservice_...pem`) into this folder.
    *   **Rename** the key file to: `private_ter.pem` (Ensure the extension is `.pem`).

2.  **Variable Setup**:
    *   Navigate to the `infrastructure/` folder.
    *   Open `terraform.tfvars` (or create it if missing).
    *   Paste/Update your OCI and server details. If you leave them blank, the server will be made with default values found in `infrastructure/variables.tf`:
        ```
        tenancy_ocid     = ""
        user_ocid        = ""
        fingerprint      = ""
        region           = ""
        compartment_id   = ""

        # Keys (Relative paths assumed)
        private_key_path     = "./ter_keys/private_ter.pem"
        ssh_public_key_path  = "./ter_keys/ssh_key.pem.pub" 
        ssh_private_key_path = "./ter_keys/ssh_key.pem" 

        # Server Hardware Configuration (Always Free Tier limits: 4 OCPUs, 24GB RAM total)
        vm_ocpus      = 2
        vm_memory_gbs = 8

        # Minecraft Game Settings
        mc_render_distance     = 16
        mc_simulation_distance = 12
        mc_gamemode            = "creative"
        mc_difficulty          = "hard"
        mc_max_players         = 20
        mc_level_seed          = "" # Leave empty for random seed
        mc_motd                = "" # Server description
        mc_online_mode         = true # Set to false for cracked clients and offline mode
        ```

4.  **Mods**:
    *   **Important**: Terraform expects the server_mods folder to exist, even if empty.
    *   Place any `.jar` server side mod files you want here.
    *   *Note: The server installs PaperMC by default. Ensure mods are compatible.*

## 4. Deployment
1.  Open **PowerShell** in the project root folder.
2.  Run the deployment script:
    ```powershell
    PowerShell -ExecutionPolicy Bypass -File .\easy_deploy.ps1
    ```
3.  **Wait**:
    *   Terraform will provision the server (Virtual Cloud Network, Compute Instance, Firewall).
    *   The script will wait for the Minecraft API to come online (this takes 2-5 minutes after the VM starts).

## 5. Connecting & Managing
Once deployment offers a **Success** message:
*   **IP Address**: The script will display the Public IP.
*   **Join Server**: In Minecraft, Direct Connect to `[IP_ADDRESS]`.
*   **Start/Stop**: The script provides commands to start/stop the server via the custom API.

## Troubleshooting
*   **Terraform Error**: Check your `tenancy_ocid`, `user_ocid`, etc. in `terraform.tfvars`.
*   **Key Error**: Ensure `private_ter.pem` is in `infrastructure/ter_keys/` and is the correct private key from OCI.
*   **Server not Starting**: SSH into the server (`ssh -i infrastructure/ter_keys/ssh_key.pem ubuntu@[IP]`) and check logs in `/var/log/user-data.log`.