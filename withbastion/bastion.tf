resource "digitalocean_droplet" "0toCloud" {
  image = "${var.do_distro}"
  name = "${var.do_hostname}"
  region = "${var.do_region}"
  size = "${var.do_size}"
  private_networking = true
  ssh_keys = [
    "${var.ssh_fingerprint}"
  ]
  
  connection {
    user = "root"
    type = "ssh"
    timeout = "2m"
    agent = "true"
  }
  
  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      "sudo apt-get update",
      "sudo apt-get -y install ufw haproxy",
      "sudo ufw default deny incoming",
      "sudo ufw default allow outgoing",
      "sudo ufw allow 22/tcp",
      "sudo ufw allow 80/tcp",
      "sudo ufw disable",
      "sudo ufw enable"

    ]
  }
}
