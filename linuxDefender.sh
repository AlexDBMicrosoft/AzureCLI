#!/bin/bash

#This script will install, configure defender and trigger an alert on the security dashboard to verify it's working.
# You'll need to define to variables here as part of the defender install

#MDE file is created from https://security.microsoft.com under , you'll need to specify the path where this file is located on the endpoint
 mdeFile=/home/linuxuser/MicrosoftDefenderATPOnboardingLinuxServer.py

 #Refer to https://packages.microsoft.com/config/ubuntu/ to see support versions of Ubuntu and specify the version you're running below
 version=""       #example "18.04"

# Install Microsoft defender linux
echo 'Installing dependencies'
sudo apt-get install -y curl libplist-utils gpg apt-transport-https
echo 'dependncies installed'
curl -o microsoft.list https://packages.microsoft.com/config/ubuntu/$version/prod.list
echo 'grabbiing microsoft repo list'
sudo mv ./microsoft.list /etc/apt/sources.list.d/microsoft-prod.list
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
echo 'doing an update to host'
sudo apt-get update
echo 'update complete'

## install defender
echo 'now installing defender'
sudo apt-get install -y mdatp

echo 'checking if associated with any org?'
mdatp health --field org_id

echo 'running deployment config'
python $mdeFile

echo 'confirming associated with correct org'
mdatp health --field org_id

echo 'verifying health. 1 is good'
mdatp health --field healthy

echo 'if not 1 - verifying if download of defintion is taking place'
mdatp health --field definitions_status
sleep 2m 

echo 'verifying health. 1 is good'
mdatp health --field healthy

echo 'checking real time protection is on'
mdatp health --field real_time_protection_enabled

echo 'simulating an attack'
curl -o /tmp/eicar.com.txt https://www.eicar.org/download/eicar.com.txt

echo 'listing threats detected'
mdatp threat list

