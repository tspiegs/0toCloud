#!/usr/bin/env bash


#is terrform an executable application? 
type terraform >/dev/null 2>&1 || { echo "Dowloading and setting up Terraform" \ 
wget https://dl.bintray.com/mitchellh/terraform/terraform_0.5.1_linux_amd64.zip \ 
echo "unzipping terrform!" \ 
sudo unzip terraform_0.5.1_linux_amd64.zip -d /usr/bin/ 
}


#checking if an rsa token exists @ ~/.ssh/id_rsa.pub and if not, creating one
if [ -a ~/.ssh/id_rsa.pub ]; then
  echo "public ssh key file exists, continuing"
else
  echo "~/.ssh/id_rsa.pub does not exists.  Would you like to create it? yes or no"
  read creatersa
  if [[ $creatersa == "yes" || $creatersa == "y" ]]; then
    echo "creating rsa key pair"
    ssh-keygen -t rsa
  else
    echo "rsa key pair exists, continuing"
  fi
fi


#checking if API key is stored in '$DO_PAT' 
if [ -z "$DO_PAT" ]; then
  echo "no PAT variable exists" #manually enter the key
  echo "enter your DigitalOcean API Key to start setting up your new droplet"
  read DOKey
else
  echo "pat exist"
  DOKey=$(echo $DO_PAT)
fi



#checking if a the rsa public key stored in ~/.ssh/id_rsa.pub exists in provided DO account, and if not, POST it there
sshkeyFP=$(ssh-keygen -lf ~/.ssh/id_rsa.pub | awk '{print $2}')
curlkeystatus=$(curl -X GET -H 'Content-Type: application/json' -H 'Authorization: Bearer 36357c32fc84612f6a0dc937b9c8da4ea49a51a8955c43debfeae29ff6ec392f'  "https://api.digitalocean.com/v2/account/keys" | grep -ci $sshkeyFP)
if [ $curlkeystatus -eq 0 ]
then
  echo "Putting your SSH key in DO"
  sshkeypub=$(cat ~/.ssh/id_rsa.pub)
  apijson=$(echo "{\"name\":\"My SSH Public Key\",\"public_key\":\"$sshkeypub\"}")
  curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $DO_PAT" -d "$apijson" "https://api.digitalocean.com/v2/account/keys"
elif [ $curlkeystatus -eq 1 ]; then
  echo "SSH Key properly in DO account, Continuing…."
else
  echo "can't detect ssh key status, something is VERY wrong here……"
fi


#now starting terraform magic and creating the instance

terraform apply -var "do_token=${DOKey}" -var "ssh_fingerprint=${sshkeyFP}" 

terraform show
