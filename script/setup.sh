
echo "THIS IS A POST INSTALLATION"
check_network() {
    ping -c 1 8.8.8.8 > /dev/null 2>&1
    return $?
}

# Check if network is working
if check_network; then
    echo "Network is working fine."
else
    echo "Network is not working. Starting NetworkManager..."
    sudo systemctl start NetworkManager
    sudo systemctl enable NetworkManager
    sleep 5  # Give NetworkManager some time to establish a connection
    if check_network; then
        echo "NetworkManager started successfully."

    else
        echo "NetworkManager failed to start. Please check your network configuration."
        echo "----------------------------------------------------------------------------------------------------------" 
        echo "----configure network then restart the script----"
        echo "----------------------------------------------------------------------------------------------------------" 
        exit 1
    fi
fi
echo "----------------------------------------------------------------------------------------------------------"
# Install graphics drivers based on user input
echo "select a graphics driver"
echo "1.amd"
echo "2.intel"
echo "3.nvdia"
read GRAPHICS
if [[ $GRAPHICS == '1' ]]; then

sudo pacman -S xf86-video-amdgpu --noconfirm --needed


elif [[ $GRAPHICS == '2' ]]; then

sudo pacman -S xf86-video-intel --noconfirm --needed

elif [[ $GRAPHICS == '3' ]]; then

sudo pacman -S nvidia nvidia-utils --noconfirm --needed

else 
   echo "INVALID OPTION. TERMINATING........."
   exit 1
fi

echo "PLEASE CHOOSE UR DESKTOP ENVIRONMENT"
echo "1.BSPWM :-is a tiling window manager that represents windows as the leaves of a full binary tree. "
echo "2.gnome :-is a desktop environment that aims to be simple and easy to use"
read user_input

# Install desktop environment based on user input

if [[ $user_input == '1' ]]; then

   sudo pacman -S xorg xorg-xinit bspwm sxhkd dmenu nitrogen picom xfce4-terminal chromium arandr --noconfirm --needed
   
   if [ ! -d .config ]; then

      mkdir -p .config;

   fi
      mkdir -p .config/bspwm
      mkdir -p .config/sxhkd
   cp /usr/share/doc/bspwm/examples/bspwmrc .config/bspwm/
   cp /usr/share/doc/bspwm/examples/sxhkdrc .config/sxhkd/

   sed -i 's/urxvt/xfce4-terminal/' .config/sxhkd/sxhkdrc
   cp /etc/X11/xinit/xinitrc .xinitrc
   sudo sed -i 's/vsync = true;/#vsync = true;/' /etc/xdg/picom.conf
   
elif [[ $user_input == '2' ]]; then

   sudo pacman -S gdm gnome --noconfirm --needed
   systemctl enable gdm
   
else
   echo "INVALID OPTION. TERMINATING........."
   exit 1
fi
echo "----------------------------------------------------------------------------------------------------------"
echo "----INSTALLATION FINISHED----"
echo "you can reboot...................."
echo "----------------------------------------------------------------------------------------------------------"