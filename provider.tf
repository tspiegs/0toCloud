variable "do_token" {}
variable "ssh_fingerprint" {}
variable "do_distro" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
