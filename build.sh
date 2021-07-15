#!/bin/bash

#Purpose of this script is to create the basic resource group and vnet for the resources to sit in. 
#The only items that need your attention are the variables listed below.

##### ATTENTION #########
# You'll need to define #
# the variables below   #
#########################

location=              #Set region to Australia East. 'az account list-locations -o table'
ResourceGroupName=                 #Resource Group name
vnetName=$ResourceGroupName         #Vnet name, reusing the same as resource group
PrivateSubnetName=                #Private vNet name
myNetworkSecurityGroup=         #NSG name

##### ATTENTION ###########
# NO CHANGE REQUIRED FROM #
#       DOWN              #
###########################

echo "Do you want to Build an environment, delete your environment, build VMs from existing environment or cancel?"
select yn in "Build_Environment" "Delete_Environment" "Build_VMs" "Cancel"; do
    case $yn in
        Build_Environment)
        echo 'Creating resource group...';
        # Create a resource group.
        az group create --name $ResourceGroupName --location $location;
        echo 'Resource Group' $ResourceGroupName 'has been created';
        echo 'Creating virtual network....'
        # Create a virtual network.
        az network vnet create --resource-group $ResourceGroupName --name $vnetName --subnet-name $PrivateSubnetName;
        echo 'Virtual Network' $vnetName 'has been created';
        echo 'Creating nsg....';
        # Create a network security group.
        az network nsg create --resource-group $ResourceGroupName --name $myNetworkSecurityGroup;
        echo 'NSG' $myNetworkSecurityGroup "has been created\n\n\n";
            select reply in "win" "linux" "both" "cancel"; do
                case $reply in  
                    win ) . ./winVM.sh; break;;
                    linux ) . ./linuxVMs.sh; break;;
                    both ) . ./winVM.sh & . ./linuxVMs.sh; break;;
                    cancel ) echo 'bye'; exit;;
                esac
            done; break;;
        Delete_Environment ) az group delete --name $ResourceGroupName --yes; break;;
        Build_VMs ) echo 'Do you want to build windows, linux or both VM types?'
            select reply in "win" "linux" "both" "cancel"; do
                case $reply in  
                    win ) . ./winVM.sh; break;;
                    linux ) . ./linuxVMs.sh; break;;
                    both ) . ./winVM.sh & . ./linuxVMs.sh; break;;
                    cancel ) echo 'bye'; exit;;
                esac
            done; break;; 
        Cancel ) echo 'Bye'; exit;;
    esac
done