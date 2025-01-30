

LOGFILE="/var/log/myscript.log"
trap "echo \"[$(date '+%Y-%m-%d %H:%M:%S')] ERROR on line $LINENO: Command failed\" | tee -a \"$LOGFILE\"" ERR
set -e  

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
  }
arch_chroot_operation()
{ local USER
install_dependencies()
{   
    echo "----------------------------------------------------------------------------------------------------------"
    log "Setup Dependencies"
    echo "----------------------------------------------------------------------------------------------------------"
    pacman -S networkmanager network-manager-applet wireless_tools git reflector base-devel --noconfirm --needed
    pacman -S grub efibootmgr wpa_supplicant mtools dosfstools linux-headers less --noconfirm --needed
    echo "----------------------------------------------------------------------------------------------------------"
}
timezone_AND_keyboard_layout()
{
    log "setting timezone"
    set_timezone() {
        echo "Available timezones:"
        timedatectl list-timezones | less
    
        echo "Enter your timezone (e.g., Asia/Kolkata):"
        read TIMEZONE
    
        if timedatectl list-timezones | grep -q "^$TIMEZONE$"; then
            ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
            echo "Timezone set to $TIMEZONE."
            log "timezone is saved:"
            echo $TIMEZONE | tee -a "$LOGFILE"
        else
            echo "Error: Invalid timezone. Please try again."
            set_timezone
            
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
    log "keyboard layout:en_US.UTF-8 UTF-8" | tee -a "$LOGFILE"
    sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
    locale-gen
    
    #create locale.conf
    echo "LANG=en_US.UTF-8" >> /etc/locale.conf
}

user_system_setup(){
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
}
post_installation_needed(){    
    echo "DO U NEED TO CLONE POST INSTALLTION SCRIPT (y/n): "
    read CONFIRM_post
    
    if [[ $CONFIRM_post == 'y' || $CONFIRM_post == 'Y' ]]; then
    curl -o /home/$USER/post_installation.sh https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/post_installation.sh
    log "the post_installation script is cloned"
    log "U are safe to reboot "
    log "---BASE INSTALLATION FINISHED---"
    exit 1
    else
    echo "----------------------------------------------------------------------------------------------------------"
    echo "---BASE INSTALLATION FINISHED---"
    echo "----------------------------------------------------------------------------------------------------------"
    echo "YOU CAN REBOOT NOW"
    fi
}
install_dependencies
timezone_AND_keyboard_layout
user_system_setup
# post_installation_needed
}

main()
{
    arch_chroot_operation
}

main