

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
        choice=${choice,,}
        if [[ $choice == "y" ]]; then
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

    log "Setting up system"

    
    echo "Enter the hostname"
    read HOSTNAME
    
echo $HOSTNAME >> /etc/hostname

cat <<EOF > /etc/hosts
    127.0.0.1	localhost
    ::1			localhost
    127.0.1.1	$HOSTNAME.localdomain	$HOSTNAME
EOF
    password(){
        local which_user=$1
        local choice=$2
        local temp_password
        while true;do
            echo "Enter the $which_user password: "
            read -sr temp_password
            echo "ReEnter the password:"
            read -sr confirm_password
            if [[ "$temp_password" == "$confirm_password" ]]; then            
                log "Setting password..."
                echo -e "$temp_password\n$temp_password" | passwd "$which_user"
            
                if [[ "$choice" == 'y' ]]; then
                    echo -e "$temp_password\n$temp_password" | passwd root
                fi
             
                return
            else
                echo "Error: Passwords do not match. Exiting..."
            fi    
        done

    }

    echo "do u want root and user password same(y/n):"
    read -r pass_choice
    pass_choice=${pass_choice,,}
    echo "enter the username"
    read -r USER
    useradd -m $USER
    usermod -aG wheel,storage,power,audio $USER

    if [[ "$pass_choice" == 'y' ]];then

        password "$USER" "y"
    else
        password "root"
        password "$USER"
    fi

    log 'editing the sudeors file to give members of wheel group to get sudo access'
    sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
    
    echo "---Inittializing the bootloader---"

    log "initializing grub"    
    
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
    
    systemctl start NetworkManager
    systemctl enable NetworkManager
}
post_installation_needed(){    
    echo "DO U NEED TO CLONE POST INSTALLTION SCRIPT (y/n): "
    read CONFIRM_post
    CONFIRM_post=${CONFIRM_post,,}
    if [[ $CONFIRM_post == 'y' ]]; then
    curl -o /home/$USER/setup.sh https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/script/setup.sh
    log "the post_installation script is cloned"
    log "U are safe to reboot "
    log "BASE INSTALLATION FINISHED"
    exit 1
    else
    log "BASE INSTALLATION FINISHED" 

    echo "YOU CAN REBOOT NOW"
    fi
}
unmount_partion(){
        umount -R /mnt
    }
install_dependencies
timezone_AND_keyboard_layout
user_system_setup
post_installation_needed
unmount_partion
}

main()
{
    arch_chroot_operation
}

main