This is a easy way for beginners to automatically startup a cloud server

run 0tocloud.sh --help to see usage

CURRENTLY UBUNTU ONLY! will be working on OSX when I have time :)

Running the startup script will (after a few more commits):
  1.  Download Terraform
  2.  Unzip terraform download into your path
  3.  Check if you have an rsa pair and make it if you don't
  4.  Ask for your DigitalOcean API Key
  5.  Place Public RSA Key in DO Account
  6.  setup a small DigitalOcean Droplet
  7.  give you an IP address that you should be able to reach via SSH

More to come.  
