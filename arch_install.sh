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
LOGFILE="/var/log/myscript.log"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}
check_network() {
    ping -c 1 8.8.8.8 > /dev/null 2>&1
    return $?
}
if check_network; then
    echo "network is up"
else
    echo "network is down"
    exit 1
# checking for uefi
log "Checking if the system is booted in UEFI mode..."
if [[ -d /sys/firmware/efi/fw_platform_size ]]; then 
    log "System is booted in UEFI mode, proceeding..."
    echo "----------------------------------------------------------------------------------------------------------"
    echo "---USER INPUT---"
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1) "
    read -r EFI
    echo "Please enter root (/) partition: (example /dev/sda2) "
    read -r ROOT
    echo "Please enter Home partition: (example /dev/sda3) "
    read -r HOME
    # echo "do u need swap partition: (y/n) "
    # read swap_need

    # if [[ $swap_need == 'y' ]]; then
    #     echo "Please enter SWAP paritition: (example /dev/sda4)"
    #     read SWAP
    #     mkswap $SWAP
    #     swapon $SWAP
    # fi

    # formating the partion and creating home and efi dir and mounting the partition(root,home,efi)
    echo -e "\nCreating Filesystems...\n"
    echo "do u need to FORMAT HOME partition: (y/n) "
    read HOME_format_needed
    if [[ $HOME_format_needed == 'y' ]]; then
        log "Formatting HOME partition..."
        mkfs.ext4 $HOME

    fi

    log "Formatting EFI partition..."
    mkfs.fat -F 32 $EFI

    log "Formatting ROOT partition..."
    mkfs.ext4 $ROOT
    
    log "Mounting ROOT partition..."
    mount $ROOT /mnt

    log "Mounting EFI partition..."
    mkdir -p /mnt/boot/efi
    mount $EFI /mnt/boot/efi

    log "Mounting HOME partition..."
    mkdir /mnt/home/
    mount $HOME /mnt/home/

    # installing the packages 

    log "Installing base packages..."
    
    pacstrap -K /mnt base linux linux-firmware nano --noconfirm --needed

    log "Generating fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab

log "Preparing next stage script..."
cat << 'REALEND' > /mnt/next.sh

# setting timezone
set_timezone() {
    echo "Available timezones:"
    timedatectl list-timezones | less

    echo "Enter your timezone (e.g., Asia/Kolkata):"
    read TIMEZONE

    if timedatectl list-timezones | grep -q "^$TIMEZONE$"; then
        ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        echo "Timezone set to $TIMEZONE."
    else
        echo "Error: Invalid timezone. Please try again."
        exit 1
    fi
}
auto_timezone=$(curl -s https://ipapi.co/timezone)

if [[ -n $auto_timezone ]]; then
    echo "Detected timezone: $auto_timezone. Do you want to use this? (y/n)"
    read -r choice
    if [[ $choice == "y" || $choice == "Y" ]]; then
        ln -sf "/usr/share/zoneinfo/$auto_timezone" /etc/localtime
        echo "Timezone set to $auto_timezone."
    else
        set_timezone # Call the manual function for user input
    fi
else
    echo "Unable to detect timezone automatically."
    set_timezone
fi
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
hwclock --systohc
#localization
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
#create locale.conf
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "----------------------------------------------------------------------------------------------------------"
echo "---Setting up system---"
echo "----------------------------------------------------------------------------------------------------------"
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
echo "----------------------------------------------------------------------------------------------------------"
echo "-- Setup Dependencies--"
echo "----------------------------------------------------------------------------------------------------------"
pacman -S networkmanager network-manager-applet wireless_tools git reflector base-devel --noconfirm --needed
pacman -S grub efibootmgr wpa_supplicant mtools dosfstools linux-headers --noconfirm --needed
echo "----------------------------------------------------------------------------------------------------------"
echo "---Inittializing the bootloader---"
echo "----------------------------------------------------------------------------------------------------------"
echo "initializing grub"
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
systemctl start NetworkManager
systemctl enable NetworkManager
echo "DO U NEED TO CLONE POST INSTALLTION SCRIPT (y/n): "
read CONFIRM_post
echo "----------------------------------------------------------------------------------------------------------"
echo "---BASE INSTALLATION FINISHED---"
echo "----------------------------------------------------------------------------------------------------------"
echo "YOU CAN REBOOT NOW"

REALEND
log "Chrooting into the new system..."
arch-chroot /mnt sh next.sh
log "Installation complete!"
else
    echo "System is not booted in uefi mode, Exiting..."
    exit 1
fi
