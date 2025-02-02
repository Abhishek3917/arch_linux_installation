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

     
DiskOperations() 
{
    local EFI ROOT HOME SWAP

    get_user_input(){
    lsblk
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

    format_and_mount(){
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

    install_base_packages(){

    log "Installing base packages..."
    
    pacstrap -K /mnt base linux linux-firmware nano --noconfirm --needed

    log "Generating fstab..."
    
    genfstab -U /mnt >> /mnt/etc/fstab
    
    log "fstab content:"
    cat /mnt/etc/fstab | tee -a "$LOGFILE"
    }
    prepare_arc_chroot(){
log "Preparing next stage script..."

rm /var/log/myscript.log  
log "Chrooting into the new system..."
curl -o /mnt/arch_config.sh https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/script/arch_config.sh
arch-chroot /mnt sh arch_config.sh
log "Installation complete!"
}
 get_user_input
 format_and_mount
 install_base_packages
 prepare_arc_chroot
 rm arch_install.sh
}
 main()
 {
    background_checks
    DiskOperations
 }

main