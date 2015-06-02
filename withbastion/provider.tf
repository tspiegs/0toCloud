variable "do_token" {}
variable "ssh_fingerprint" {}
variable "do_distro" {}
variable "do_size" {}
variable "do_region" {}
variable "do_hostname" {}

provider "digitalocean" {
  token = "${var.do_token}"
}
