# Broadcom Wi-Fi Setup & Network Activation Guide

A quick troubleshooting and setup guide for configuring Broadcom Wi-Fi network cards (specifically **BCM43142**) on Arch Linux.

---

## 1. Driver Identification & Installation

Check if the Wi-Fi card is detected by system interfaces:

```bash
ip a
```

If no Wi-Fi interface is detected, check connected PCI devices:

```bash
lspci
```

If the output identifies the device as:
> `Network controller: Broadcom Inc. and subsidiaries BCM43142 802.11b/g/n (rev 01)`

Install the required Broadcom STA proprietary driver (`broadcom-wl`):

```bash
sudo pacman -S broadcom-wl
```

Restart the NetworkManager service to apply changes:

```bash
sudo systemctl restart NetworkManager
```

---

## 2. Network Activation on Arch ISO

If you are running the Arch Linux Live ISO, use `iwd` (`iwctl`) to connect:

```bash
iwctl
```

Inside the interactive prompt, list and connect to your Wi-Fi network:

```text
station wlan0 connect <Your_SSID>
```

---

## 3. Network Connection After Reboot

Once installed and rebooted into your main Arch system, use `nmcli` to manage network connections.

List available network devices:

```bash
nmcli device
```

Connect to your Wi-Fi network:

```bash
nmcli device wifi connect "Your_SSID" password "Your_Password"
```
