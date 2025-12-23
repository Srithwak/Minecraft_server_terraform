variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "fingerprint" {}
variable "region" {}
variable "private_key_path" {}
variable "compartment_id" {}
variable "ssh_public_key_path" {}
variable "ssh_private_key_path" {}

# VM Config
variable "vm_ocpus" { default = 1 }
variable "vm_memory_gbs" { default = 6 }

# Minecraft Config
variable "mc_render_distance" { default = 10 }
variable "mc_simulation_distance" { default = 10 }

variable "mc_level_seed" {
  type    = string
  default = ""
}

variable "mc_gamemode" {
  type    = string
  default = "survival"
}

variable "mc_difficulty" {
  type    = string
  default = "easy"
}

variable "mc_max_players" {
  type    = number
  default = 20
}

variable "mc_motd" {
  type    = string
  default = "Managed by Terraform"
}

variable "mc_online_mode" {
  type    = bool
  default = false
}
