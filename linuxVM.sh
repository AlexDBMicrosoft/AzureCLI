#!/bin/bash

##### ATTENTION #########
# You'll need to define #
# the variables below   #
#########################

#Variables
VMname=                       #VMName for Linux
nicName=                      #NIC name for these VMs
adminuser=                    #Linux adminuser - can not be reserved names like 'admin' or 'administrator'. if left blank will default to OS predefined admin account. e.g azureuser
key=                          #ssh public key to use for passwordless connection. specify absolute path or keep the pub key local to where this script runs. other words same folder.
image=                        #Specify what image you want to use. 'az vm image list --output table'. Refer to the UrnAlias column
count=                        # the amount of VMs you want to build of this type. 
privatekey=                   #specify your private key location to transfer MDE config to host.
#size=                        #specify sku size 'az vm list-sizes --location australiaeast -o table' for more detail refer to: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general
### If you want to specify a sku size for the VMs, uncomment the size variable above as well as uncomment line 58 where the VM is being creeated.

##### ATTENTION #########
# Don't need to change  #
# anything here         # 
#########################

i=1

while [ $i -le $count ]
do
  echo 'Starting to build your linux VMs now.....'
  echo ''
  echo ''
  echo 'Creating Public IP....'
  az network public-ip create \
    -g $ResourceGroupName \
    -n $publicIP$VMname$i
    
  echo 'Public IP resource' $ResourceGroupName 'has been created'
  echo 'Starting to build the linux VMs now'

  echo 'Creating linux virtual nic....'$i
# Create a vnic and associate with public IP address and NSG.
  az network nic create \
    --resource-group $ResourceGroupName \
    --name $nicName$i \
    --vnet-name $vnetName \
    --subnet $PrivateSubnetName \
    --network-security-group $myNetworkSecurityGroup \
    --public-ip-address $publicIP$VMname$i
  echo 'Linux NIC' $linuxVMname$i 'has been created'
  echo 'Creating linux virtual machine....'
# Create a new virtual machine, this creates SSH keys if not present.
  az vm create \
    --name $VMname$i \
    --resource-group $ResourceGroupName \
    --nics $nicName$i \
    --image $image \
    --ssh-key-values $key \
    --admin-username $adminuser \
    #--size $size \
    --no-wait 
  
  echo 'Linux VM' $VMname$i 'has been created'
  echo ''
  echo 'Allowing SSH....'
# Open port 22 to allow SSh traffic to host.
  az vm open-port \
    --port 22 \
    --resource-group $ResourceGroupName \
    --name $VMname$i \
    --priority 10$i

  echo 'SSH ports have been opened'
  ((i++))

done

az vm list --show-details --output table