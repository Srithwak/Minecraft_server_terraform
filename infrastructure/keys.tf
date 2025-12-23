resource "tls_private_key" "mc_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.mc_key.private_key_pem
  filename        = "${path.module}/ter_keys/ssh_key.pem"
  file_permission = "0600"
}

output "ssh_private_key" {
  value     = tls_private_key.mc_key.private_key_pem
  sensitive = true
}
