#!/bin/bash
MACHINENAME=$1

# Download debian.iso
if [ ! -f ./debian.iso ]; then
    wget https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.6.0-amd64-netinst.iso -O debian.iso
fi

#Create VM
VBoxManage createvm --name $MACHINENAME --ostype "Debian_64" --register --basefolder `pwd`
#Set memory and network
VBoxManage modifyvm $MACHINENAME --ioapic on
VBoxManage modifyvm $MACHINENAME --cpus 4
VBoxManage modifyvm $MACHINENAME --graphicscontroller vmsvga
VBoxManage modifyvm $MACHINENAME --memory 2048 --vram 128
VBoxManage modifyvm $MACHINENAME --nic1 nat
VBoxManage modifyvm $MACHINENAME --natpf1 "guestssh,tcp,,2222,,22"
VBoxManage modifyvm $MACHINENAME --natpf1 "nginxhttp,tcp,,8080,,80"
VBoxManage modifyvm $MACHINENAME --natpf1 "nginxhttps,tcp,,8443,,443"
#VBoxManage modifyvm $MACHINENAME --cableconnected1 off 


#Create Disk and connect Debian Iso
VBoxManage createhd --filename `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi --size 80000 --format VDI
VBoxManage storagectl $MACHINENAME --name "SATA Controller" --add sata --controller IntelAhci
VBoxManage storageattach $MACHINENAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium `pwd`/$MACHINENAME/$MACHINENAME_DISK.vdi
VBoxManage storagectl $MACHINENAME --name "IDE Controller" --add ide --controller PIIX4
VBoxManage storageattach $MACHINENAME --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/debian.iso
VBoxManage modifyvm $MACHINENAME --boot1 dvd --boot2 disk --boot3 none --boot4 none

# Modify the VM to use the preseed file
VBoxManage unattended install $MACHINENAME \
    --iso=debian.iso \
    --user=aleonov \
    --password=1971 \
    --full-user-name="aleonov" \
    --locale=en_US \
    --time-zone=US/Eastern \
    --package-selection-adjustment=minimal


# Start the VM
VBoxHeadless --startvm $MACHINENAME
