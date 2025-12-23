data "oci_core_images" "ubuntu_images" {
  compartment_id           = var.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

locals {
  # Calculate RAM for Minecraft (Total VM RAM - 1.5GB for OS overhead)
  # Convert GB to MB: (vm_memory_gbs * 1024) - 1536
  mc_ram_mb = (var.vm_memory_gbs * 1024) - 1536
}

resource "oci_core_instance" "mc_server" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = var.compartment_id
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.vm_ocpus
    memory_in_gbs = var.vm_memory_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.mc_subnet.id
    assign_public_ip = true
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu_images.images[0].id
  }

  # New: Upload server_mods folder
  provisioner "file" {
    source      = "../server_mods"
    destination = "/home/ubuntu/mods"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_private_key_path)
      host        = self.public_ip
    }
  }

  metadata = {
    ssh_authorized_keys = tls_private_key.mc_key.public_key_openssh
    user_data           = base64encode(templatefile("./setup.sh.tftpl", {
      mc_ram_mb              = local.mc_ram_mb,
      mc_render_distance     = var.mc_render_distance,
      mc_simulation_distance = var.mc_simulation_distance,
      mc_level_seed          = var.mc_level_seed,
      mc_gamemode            = var.mc_gamemode,
      mc_difficulty          = var.mc_difficulty,
      mc_max_players         = var.mc_max_players,
      mc_motd                = var.mc_motd,
      mc_online_mode         = var.mc_online_mode
    }))
  }
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_id
}

output "public_ip" {
  value = oci_core_instance.mc_server.public_ip
}