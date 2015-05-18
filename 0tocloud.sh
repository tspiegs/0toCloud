#!/usr/bin/env bash

function usage 
{ echo "run startup script to create and destroy cloud instances 
  available distros:  "
  cat ./distros.txt
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --distro )         shift
                                distro=$1
                                ;;
        -h | --hostname )       shift
                                hostname=$1
                                ;;
        -p | --plan )           plan=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        -D | --destroy )        destroy=1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

if [ -z $distro ]; then
  distro="ubuntu-14-04-x64"
fi

#make sure unzip is installed 
type unzip >/dev/null 2>&1 || { echo "Dowloading unzip via apt-get" \ 
sudo apt-get -y install unzip
}

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
curlkeystatus=$(curl -X GET -H 'Content-Type: application/json' -H "Authorization: Bearer $DOKey"  "https://api.digitalocean.com/v2/account/keys" | grep -ci $sshkeyFP)
if [ $curlkeystatus -eq 0 ]
then
  echo "Putting your SSH key in DO"
  sshkeypub=$(cat ~/.ssh/id_rsa.pub)
  apijson=$(echo "{\"name\":\"My SSH Public Key\",\"public_key\":\"$sshkeypub\"}")
  curl -X POST -H 'Content-Type: application/json' -H "Authorization: Bearer $DOKey" -d "$apijson" "https://api.digitalocean.com/v2/account/keys"
elif [ $curlkeystatus -eq 1 ]; then
  echo "SSH Key properly in DO account, Continuing…."
else
  echo "can't detect ssh key status, something is VERY wrong here……"
fi



if [ $destroy -eq 1 ]; then
  terraform destroy -var "do_token=${DOKey}" -var "ssh_fingerprint=${sshkeyFP}" -var "do_distro=${distro}" 
  exit 1
fi

if [ $plan -eq 1 ]; then
  terraform plan -var "do_token=${DOKey}" -var "ssh_fingerprint=${sshkeyFP}" -var "do_distro=${distro}" 
  exit 1
fi

#now starting terraform magic and creating the instance

terraform apply -var "do_token=${DOKey}" -var "ssh_fingerprint=${sshkeyFP}" -var "do_distro=${distro}"

terraform show