#!/usr/bin/env bash

type terraform >/dev/null 2>&1 || { echo "Dowloading and setting up Terraform" \ 
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.5.1_linux_amd64.zip \ 
echo "unzipping terrform!" \ 
sudo unzip terraform_0.5.1_linux_amd64.zip -d /usr/bin/ 
}

