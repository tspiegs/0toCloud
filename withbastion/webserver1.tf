resource "digitalocean_droplet" "0toCloudwebserver1" {
  image = "${var.do_distro}"
  name = "0toCloudwww2"
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
      "sudo apt-get -y install nginx",
      "sudo sed -i s/working/working\ powered\ by\ 0toCloud/ /usr/share/nginx/html/index.html",
      "sudo /etc/init.d/nginx restart"
    ]
  }
}
