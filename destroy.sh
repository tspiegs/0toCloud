#!/usr/bin/env bash

#checking if API key is stored in '$DO_PAT' 
if [ -z "$DO_PAT" ]; then
  echo "no PAT variable exists" #manually enter the key
  echo "enter your DigitalOcean API Key to start setting up your new droplet"
  read DOKey
else
  echo "pat exist"
  DOKey=$(echo $DO_PAT)
fi

terraform destroy -var "do_token=${DOKey}" -var "ssh_fingerprint=${sshkeyFP}" 
