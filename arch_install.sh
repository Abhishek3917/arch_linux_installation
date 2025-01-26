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

trap "echo \"[$(date '+%Y-%m-%d %H:%M:%S')] ERROR on line $LINENO: Command failed\" | tee -a \"$LOGFILE\"" ERR

set -e  # Exit immediately if any command exits with a non-zero status

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOGFILE"
}

network_check() {
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
    echo "network is up"
        
    else
    echo "network is down"
    exit 1
fi
}

arch_check() {
    if [[ ! -e /etc/arch-release ]]; then
        echo -ne "ERROR! This script must be run in Arch Linux!\n"
        exit 0
    fi
}


efi_check(){
    if cat /sys/firmware/efi/fw_platform_size >/dev/null 2>&1; then
    log "Checking if the system is booted in UEFI mode..."
    log "System is booted in UEFI mode, proceeding..."
    
    else
    echo "System is not booted in uefi mode, Exiting..."
    exit 1
    fi
       
} 

background_checks() {
    efi_check
    network_check
    log "distro_verification"
    arch_check
    
    
}

background_checks     
DiskOperations() 
{
    local EFI ROOT HOME SWAP

    DiskOperations::get_user_input(){
    echo "----------------------------------------------------------------------------------------------------------"
    echo "---USER INPUT---"
    echo "----------------------------------------------------------------------------------------------------------"
    echo "Please enter EFI paritition: (example /dev/sda1 or /dev/nvme0n1p1) "
    read -r EFI
    echo "Please enter root (/) partition: (example /dev/sda2) "
    read -r ROOT
    echo "Please enter Home partition: (example /dev/sda3) "
    read -r HOME
    echo "do u need swap partition: (y/n) "
    read -r swap_need

    if [[ $swap_need == 'y' ]]; then
        echo "Please enter SWAP paritition: (example /dev/sda4)"
        read -r SWAP
        log "creating swap partion..."
        mkswap $SWAP
        swapon $SWAP      
        
    fi
    }

    DiskOperations::format_and_mount(){
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

    log "Checking mounted partitions..."
    mount | grep /mnt | tee -a "$LOGFILE"
    }

    DiskOperations::install_base_packages(){
    # installing the packages 

    log "Installing base packages..."
    
    pacstrap -K /mnt base linux linux-firmware nano --noconfirm --needed

    log "Generating fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
    
    log "fstab content:"
    cat /mnt/etc/fstab | tee -a "$LOGFILE"
    }
    DiskOperations::prepare_arc_chroot(){
log "Preparing next stage script..."
cat << 'REALEND' > /mnt/next.sh
set -e  # Exit immediately if any command exits with a non-zero status

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  }
echo "----------------------------------------------------------------------------------------------------------"
echo "-- Setup Dependencies--"
echo "----------------------------------------------------------------------------------------------------------"
pacman -S networkmanager network-manager-applet wireless_tools git reflector base-devel --noconfirm --needed
pacman -S grub efibootmgr wpa_supplicant mtools dosfstools linux-headers less --noconfirm --needed
echo "----------------------------------------------------------------------------------------------------------"

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

echo "---Inittializing the bootloader---"
echo "----------------------------------------------------------------------------------------------------------"
echo "initializing grub"

grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl start NetworkManager
systemctl enable NetworkManager

echo "DO U NEED TO CLONE POST INSTALLTION SCRIPT (y/n): "
read CONFIRM_post

if [[ $CONFIRM_post == 'y' || $CONFIRM_post == 'Y' ]]; then
curl -o /home/$USER/post_installation.sh https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/post_installation.sh
log "the post_installation script is cloned"
log "U are safe to reboot "
log "---BASE INSTALLATION FINISHED---"
exit 1
fi
echo "----------------------------------------------------------------------------------------------------------"
echo "---BASE INSTALLATION FINISHED---"
echo "----------------------------------------------------------------------------------------------------------"
echo "YOU CAN REBOOT NOW"

REALEND
    
log "Chrooting into the new system..."
arch-chroot /mnt sh next.sh
log "Installation complete!"
 }
}
 main()
 {
    DiskOperations
    DiskOperations::execute
 }

