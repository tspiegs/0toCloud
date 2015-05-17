resource "digitalocean_droplet" "0toCloud" {
  image = "${var.do_distro}"
  name = "0toCloud"
  region = "nyc2"
  size = "512mb"
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
      "sudo apt-get -y upgrade"
    ]
  }
}
