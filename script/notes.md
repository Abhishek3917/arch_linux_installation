if wifi not detected run ip a if now wifi card detected
run lspci
if Netwok controller: Broadcom Inc. and subsidiaries BCM43142 802.11b/g/n (rev 01)
then pacman -S broadcom-wl // because Broadcom BCM43142 802.11b/g/n needs the Broadcom STA driver.

sudo systemctl restart NetworkManager

network activation

on arch-iso

iwctl 
station wifiadaptor(wlan0) connect wifiname

on reboot
nmcli device // to list available devices
nmcli device wifi connect "Your_SSID" password "Your_Password"
