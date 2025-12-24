# Project Journey

This document chronicles the evolution of this Minecraft server project. It wasn't built in a day; it started as a manual experiment and evolved into a fully automated Infrastructure-as-Code solution. The goal of this project was not just to play Minecraft, but to master Cloud Infrastructure and DevOps practices.

## Phase 1: The Manual Approach (The "Hard Way")
Initially, I started by manually provisioning a Virtual Machine on Oracle Cloud Infrastructure (OCI).

*   **The Goal**: Get a simple PaperMC server running on an ARM-based Ampere instance (Always Free tier).
*   **The Process**:
    *   Manually clicked through the OCI console to create instances.
    *   **The Struggle**: Networking. Understanding Virtual Cloud Networks (VCNs), Subnets, and Security Lists was a steep learning curve.
        *   *Issue*: I opened the localized firewall (`iptables`) on the VM but forgot the Oracle Cloud Security List. spent hours wondering why I couldn't connect.
        *   *Issue*: SSH Key permission errors (`WARNING: UNPROTECTED PRIVATE KEY FILE!`). Learned the hard way about `chmod 400`.
    *   **Dependencies**: Manually installing Java (`openjdk-21`). First attempted with Java 17, then realized modern Minecraft requires newer versions.
    *   **Persistence**: `screen` sessions. I had to manually start `screen`, run the jar, and detach. If the server rebooted, everything went down.

## Phase 2: Improving Usability (Python API)
Once the server was running manually, managing it was annoying. I didn't want to SSH in every time just to restart the server or check if it crashed.

*   **The Solution**: I wrote a light-weight Python Flask API (`server_manager.py`) to run on the server alongside Minecraft.
*   **Features**:
    *   `/start`, `/stop`, and `/status` endpoints.
    *   This allowed me to build simple webhooks or local scripts to control the server without touching the terminal.
*   **Challenges**:
    *   **Process Management**: How does a Python script talk to a running `screen` session? I had to learn how to inject commands into `screen` using `stuff`.
    *   **Systemd**: To make the API run 24/7, I had to create a custom `systemd` service file. I broke this multiple times by getting the `WorkingDirectory` wrong.

## Phase 3: The Shift to Terraform (Infrastructure as Code)
I realized that if I ever wanted to delete the server and start over, I'd have to do all that manual work again. Enter **Terraform**.

*   **The Goal**: One command (`terraform apply`) to build the entire infrastructure.
*   **The Learning Curve**:
    *   **HCL Syntax**: Learning how to define resources, variables, and outputs.
    *   **Cloud-Init (`user_data`)**: This was the hardest part. I had to write a bash script (`setup.sh`) that Terraform injects into the server on first boot.
    *   **Debugging Nightmare**:
        *   The script would fail silently. I had to add logging lines (`exec > >(tee /var/log/user-data.log...`) to even see what was going wrong.
        *   *DNS Issues*: The server couldn't download PaperMC because OCI's default DNS sometimes flaked out. I added a hack to force `8.8.8.8` in `resolv.conf`.
        *   *Template Files*: Passing variables from Terraform to the bash script using `templatefile()`. I struggled with syntax errors where Terraform wouldn't interpolate the variables correctly.
    *   **State Locking**: I ran into issues where Terraform's state file got locked because I crtl-c'd a process too early, requiring manual unlocking.

## Phase 4: Refinement & Features
Once the base automation worked, I started adding "quality of life" features.

*   **Mod Support**:
    *   I realized I wanted to play with mods. I added a `file` provisioner in Terraform to upload a local `server_mods` folder to the server automatically.
    *   *Challenge*: Permissions. The uploaded files were owned by `root` initially, causing the server to crash. Added `chown` commands to fix it.
*   **Configuration**:
    *   Hardcoding values in the script was bad practice. I moved everything to `variables.tf` and `terraform.tfvars`.
    *   Added support for custom RAM allocation, game difficulty, and seeds.
*   **Online Mode Toggle**:
    *   Most recently, I added the ability to toggle `online-mode` (true/false) from Terraform, which required threading a boolean variable all the way from `tfvars` to the `server.properties` file.

## Phase 5: Total Automation & Refinement
The goal for this phase was to remove "friction" for new users. I noticed that setting up SSH keys and finding Compartment IOs were major stumbling blocks.

*   **SSH Key Automation**:
    *   Previously, the user had to generate their own SSH keys and paste paths.
    *   I introduced `tls_private_key` resource in Terraform to generate keys on the fly and save them to `ter_keys/ssh_key.pem`.
    *   Now, `compute.tf` references the generated key directly, meaning the user never has to worry about SSH keys unless they want to log in.
*   **Compartment Simplification**:
    *   Users were confused about what "Compartment ID" to use.
    *   I realized the "Tenancy OCID" *is* the Root Compartment ID.
    *   I removed the `compartment_id` variable and updated all resources to default to `var.tenancy_ocid`. This eliminated a configuration step and a potential source of error.
*   **Login Session Fixes**:
    *   Encountered "Invalid Login Session" errors.
    *   Set `mc_online_mode = false` by default (or toggleable) to allow easier testing and connection without complex Mojang authentication setups.

## Conclusion
What started as "I just want a Minecraft server" turned into a crash course in Cloud Engineering.

**Key Takeaways**:
1.  **Automation is worth the initial pain**: It took 3x longer to write the Terraform script than to build the server manually once. But now I can rebuild it in 3 minutes.
2.  **Logs are life**: Without creating custom logging for the startup script, debugging cloud instances is impossible.
3.  **Security Layers**: Firewalls exist at the Cloud level (OCI Security Lists) *and* the OS level (`iptables`). You have to punch holes in both.
