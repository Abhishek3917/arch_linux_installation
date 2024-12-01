#!/usr/bin/bash
echo "----------------------------------------------------------------------------------------------------------

                                                                                         
   ##   #####   ####  #    #    # #    #  ####  #####   ##   #      #      ###### #####  
  #  #  #    # #    # #    #    # ##   # #        #    #  #  #      #      #      #    # 
 #    # #    # #      ######    # # #  #  ####    #   #    # #      #      #####  #    # 
 ###### #####  #      #    #    # #  # #      #   #   ###### #      #      #      #####  
 #    # #   #  #    # #    #    # #   ## #    #   #   #    # #      #      #      #   #  
 #    # #    #  ####  #    #    # #    #  ####    #   #    # ###### ###### ###### #    # 
                                                                                         
  
----------------------------------------------------------------------------------------------------------" 

echo "checking is system is booted in uefi mode"
sleep_(){
    sleep 4
}

arch_install() {
     echo "Systerm is booted in uefi mode, procedding....."
    
    echo "---USER INPUT---"
    
    echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1) "
    read EFI
    echo "Please enter root (/) partition: (example /dev/sda2) "
    read ROOT
    echo "Please enter Home partition: (example /dev/sda3) "
    read HOME
    # echo "do u need swap partition: (y/n) "
    # read swap_need

    # if [[ $swap_need == 'y' ]]; then
    #     echo "Please enter SWAP paritition: (example /dev/sda4)"
    #     read SWAP
    #     sleep_()
    #     mkswap $SWAP
    #     swapon $SWAP
    # fi

    # formating the partion and creating home and efi dir and mounting the partition(root,home,efi)
    echo -e "\nCreating Filesystems...\n"
    echo "do u need to FORMAT HOME partition: (y/n) "
    read HOME_format_needed
    sleep_()
    if [[ $HOME_format_needed == 'y' ]]; then
        mkfs.ext4 $HOME
        sleep_()
        mkdir /mnt/home/
        mount $HOME /mnt/home/
    fi
    mkfs.fat -F 32 $EFI
    mkfs.ext4 $ROOT
    sleep_()
    echo -e "\nMounting the disk...\n"
    mount $ROOT /mnt
    sleep_()
    mkdir -p /mnt/boot/efi
    mount $EFI /mnt/boot/efi
    sleep_()
    # installing the packages 
    
    echo "---Install essential packages---"
    
    pacstrap -K /mnt base linux linux-firmware nano --noconfirm --needed
    sleep_()
    # generating the genfstab
    echo "Generating an fstab file........."
    genfstab -U /mnt >> /mnt/etc/fstab

cat << 'REALEND' > /mnt/next.sh

# setting timezone
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
#localization
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
#create locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

echo "---Setting up system---"

echo "Enter the hostname"
read HOSTNAME
echo $HOSTNAME >> /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1			localhost
127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME
EOF
echo "root user password"
passwd
echo "enter the usernmae"
read USER
useradd -m $USER
usermod -aG wheel,storage,power,audio $USER
passwd $USER
#editing the sudeors file to give members of wheel group to get sudo access
sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

echo "-- Setup Dependencies--"

pacman -S networkmanager network-manager-applet wireless_tools git reflector base-devel --noconfirm --needed
sleep_()
pacman -S grub efibootmgr wpa_supplicant mtools dosfstools linux-headers --noconfirm --needed
sleep_()
echo "---Inittializing the bootloader---"

echo "initializing grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl start NetworkManager
systemctl enable NetworkManager
echo "DO U NEED TO CLONE POST INSTALLTION SCRIPT (y/n): "
read CONFIRM_post

echo "---BASE INSTALLATION FINISHED---"

echo "YOU CAN REBOOT NOW"

REALEND

arch-chroot /mnt sh next.sh
}

if cat /sys/firmware/efi/fw_platform_size >/dev/null 2>&1; then # checking for uefi

arch_install

else
    echo "System is not booted in uefi mode, Exiting..."
    exit 1
fi
