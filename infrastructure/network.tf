resource "oci_core_vcn" "mc_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.compartment_id
  display_name   = "MinecraftVCN"
}

resource "oci_core_internet_gateway" "mc_ig" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.mc_vcn.id
}

resource "oci_core_default_route_table" "mc_rt" {
  manage_default_resource_id = oci_core_vcn.mc_vcn.default_route_table_id
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.mc_ig.id
  }
}

resource "oci_core_security_list" "mc_sl" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.mc_vcn.id
  display_name   = "MinecraftSecurityList"

  # SSH
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }

  # Minecraft
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 25565
      max = 25565
    }
  }

  # Web Manager
  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      min = 8080
      max = 8080
    }
  }
  
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "mc_subnet" {
  cidr_block        = "10.0.1.0/24"
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.mc_vcn.id
  security_list_ids = [oci_core_security_list.mc_sl.id]
}