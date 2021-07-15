#!/bin/bash

#Purpose of this script is to create

#Variables
VMname=                    #vmName for windows
nicName=                   #NIC name for these VMs
adminuser=                 #Linux adminuser - can not be reserved names like 'admin' or 'administrator'. if left blank will default to OS predefined admin account. e.g azureuser
adminPassword=             #admin password for the above account.
image=                     #Specify what image you want to use. 'az vm image list --output table'. Refer to the UrnAlias column
count=1                    # the amount of VMs you want to build of this type. 
assignee=                  #specify AAD account you want to have access to these VMs
role=                      #specify which role will be assigned to allow RDP when using AAD account. Options are "Virtual Machine Administrator Login" or "Virtual Machine Administrator Login or Virtual Machine User Login"
#size=                     #specify sku size 'az vm list-sizes --location australiaeast -o table' for more detail refer to: https://docs.microsoft.com/en-us/azure/virtual-machines/sizes-general
### If you want to specify a sku size for the VMs, uncomment the size variable above as well as uncomment line 53 where the VM is being creeated.

##### ATTENTION #########
# Don't need to change  #
# anything here         # 
#########################

i=1

while [ $i -le $count ]
do
  echo 'Starting to build your Windows VMs now.....'
  echo ''
  echo ''
  echo 'Creating Public IP....'
  az network public-ip create -g $ResourceGroupName -n $publicIP$VMname$i
  echo 'Public IP resource' $ResourceGroupName 'has been created'
  echo 'Starting to build the windows VMs now'

  echo 'Creating windows virtual nic....'$i
# Create a vnic and associate with public IP address and NSG.
  az network nic create \
    --resource-group $ResourceGroupName \
    --name $nicName$i \
    --vnet-name $vnetName \
    --subnet $PrivateSubnetName \
    --network-security-group $myNetworkSecurityGroup \
    --public-ip-address $publicIP$VMname$i
  echo 'Windows NIC' $VMname$i 'has been created'
  echo 'Creating Windows virtual machine....'
# Create a new virtual machine
  az vm create \
    --name $VMname$i \
    --resource-group $ResourceGroupName \
    --nics $nicName$i \
    --image $image \
    --admin-username $adminuser \
    --admin-password $adminPassword \
    #--size $size \
    --assign-identity \
    --no-wait
  
  echo 'adding AAD extension'
  az vm extension set \
    --publisher Microsoft.Azure.ActiveDirectory \
    --name AADLoginForWindows \
    --resource-group $ResourceGroupName \
    --vm-name $VMname$i
    
  echo 'Windows VM' $VMname$i 'has been created'
  
  echo 'Allowing RDP....'
# Open port 3389 to allow RDP traffic to host.
  az vm open-port --port 3389 --resource-group $ResourceGroupName --name $VMname$i --priority 20$i
  echo 'RDP ports have been opened'

  echo 'disable network level authentication so that you can login with AAD'
  az vm run-command invoke --command-id DisableNLA -n $VMName$i -g $ResourceGroupName 

  ((i++))
  
done

echo 'Assign Virtual admin or Virtual user role to the resource group so that you can login with AAD'
az role assignment create \
  --assignee $assignee \
  --role $role \
  --resource-group $ResourceGroupName