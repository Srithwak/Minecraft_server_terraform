variable "tenancy" {}
variable "user" {}
variable "fingerprint" {}
variable "region" {}

variable "private_key_path" {
  type    = string
  default = "./infrastructure/ter_keys/private_ter.pem"
}



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
  default = true
}

variable "mc_server_type" {
  type    = string
  default = "fabric"
}

variable "fabric_installer_version" {
  type    = string
  default = "1.0.1"
}

variable "fabric_loader_version" {
  type    = string
  default = "0.17.3"
}

variable "mc_version" {
  type    = string
  default = "1.21.11"
}
