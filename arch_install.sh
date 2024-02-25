#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------
                            ###                 ##                         ##               ###      ###    
                             ##                                            ##                ##       ##    
  ####    ######    ####     ##                ###     #####     #####    #####    ####      ##       ##    
     ##    ##  ##  ##  ##    #####              ##     ##  ##   ##         ##         ##     ##       ##    
  #####    ##      ##        ##  ##             ##     ##  ##    #####     ##      #####     ##       ##    
 ##  ##    ##      ##  ##    ##  ##             ##     ##  ##        ##    ## ##  ##  ##     ##       ##    
  #####   ####      ####    ###  ##            ####    ##  ##   ######      ###    #####    ####     ####   
----------------------------------------------------------------------------------------------------------" 

echo "checking is system is booted in uefi mode"
if cat /sys/firmware/efi/fw_platform_size >/dev/null 2>&1; then
    echo "Systerm is booted in uefi mode, procedding....."
    echo "----------------------------------------------------------------------------------------------------------"
    echo "---USER INPUT---"
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1) "
    read EFI
    echo "Please enter root (/) partition: (example /dev/sda3) "
    read ROOT
    echo "Please enter Home partition: (example /dev/sda2) "
    echo HOME
    echo "do u need swap partition: (y/n) "
    read swap_need
    if [[ $swap_need == 'y' ]]; then
        echo "Please enter SWAP paritition: (example /dev/sda4)"
        read SWAP
        echo $SWAP
        mkswap $SWAP
        swapon $SWAP
    fi
    echo -e "\nCreating Filesystems...\n"
    echo "do u need FORMAT HOME partition: (y/n) "
    read HOME_format_needed
    if [[ $HOME_format_needed == 'y' ]]; then
        mkfs.ext4 $HOME
        mount --mkdir $HOME /mnt/home
    fi
    mkfs.fat -F 32 $EFI
    mkfs.ext4 $ROOT
    
    echo -e "\nMounting the disk...\n"
    mount $ROOT /mnt
    mount --mkdir $EFI /mnt/boot/efi
    echo "----------------------------------------------------------------------------------------------------------"
    echo "---Install essential packages---"
    echo "----------------------------------------------------------------------------------------------------------"
    pacstrap -K /mnt base linux linux-firmware nano base-devel --noconfirm --needed
    echo "----------------------------------------------------------------------------------------------------------"
    echo "-- Setup Dependencies--"
    echo "----------------------------------------------------------------------------------------------------------"
    pacstrap /mnt networkmanager network-manager-applet wireless_tools nano git --noconfirm --needed
    echo "Generating an fstab file........."
    genfstab -U /mnt >> /mnt/etc/fstab
else
    echo "System is not booted in uefi mode, Exiting..."
    exit 1
fi
