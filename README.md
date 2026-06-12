# 🚀 Arch Linux Automated Installer 

## 📌 Project Details

This project offers an interactive Bash-based installer that streamlines the Arch Linux installation process.

It automates basic installation activities while keeping the setup process transparent and adjustable for those that prefer greater control over their machine.

The installer helps with:


* Disk preparation and mounting.
* Basic Arch Linux installation

* Bootloader configuration

* Create a user account.

* Network setup.

* System localization.

* Optional post-installation configuration.

The goal of this project is to make Arch Linux installation faster and easier, particularly for those who prefer a guided setup over manually inputting each command.

---

# ✨ Features

## ⚡ Automated Installation

The installer performs:

✅ UEFI boot detection
✅ Network connectivity check
✅ Arch Linux environment verification
✅ Package installation
✅ Filesystem creation
✅ Partition mounting
✅ fstab generation

---

## 💾 Disk Management

Supports:

* EFI partition
* Root partition
* Home partition
* Optional swap partition

Example layout:

```
/dev/sda1  → EFI
/dev/sda2  → Root
/dev/sda3  → Home
/dev/sda4  → Swap
```

---

## 🔧 System Configuration

Automatically configures:

* Hostname
* Users
* Passwords
* sudo permissions
* Locale
* Keyboard settings
* Hardware clock

---

## 🥾 Bootloader Setup

Installs and configures:

* GRUB
* EFI boot entry

---

## 🌐 Network Setup

Installs and enables:

* NetworkManager
* Wireless tools
* wpa_supplicant

After reboot:

```bash
systemctl status NetworkManager
```

---

# 🏗️ Project Structure

```
arch_linux_installation
│
├── arch_install.sh
│
├── script
│   │
│   ├── arch_config.sh
│   │
│   └── setup.sh
│
└── README.md
```

## Installation Flow

```
Live ISO
   |
   |
arch_install.sh
   |
   |
Partition Setup
   |
   |
pacstrap Base System
   |
   |
arch_config.sh
   |
   |
GRUB + User Setup
   |
   |
Reboot
   |
   |
Optional Setup Script
```

---

# ⚠️ Requirements

Before running:

## 1. Boot Arch Linux ISO

Create a bootable USB:

https://archlinux.org/download/

Boot into the live environment.

---

## 2. Check Internet

```bash
ping google.com
```

---

## 3. Create partitions

Example:

```bash
fdisk -l
```

Create:

* EFI partition
* Root partition
* Home partition (optional)
* Swap partition (optional)

---

# 🚀 Usage

Download installer:

```bash
curl -O https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/arch_install.sh
```

Make executable:

```bash
chmod +x arch_install.sh // optional as in arch_installation
```

Run:

```bash
./arch_install.sh or sh arch_install.sh
```

Follow the interactive prompts.

---

# 🔐 Security Warning

This script performs destructive operations.

It can:

* Format partitions
* Delete existing data
* Modify bootloader
* Create users

Always:

* Read the script before running
* Verify partitions
* Test inside a VM first

---

# 🧪 Testing

Recommended testing environments:

## VirtualBox

Suggested:

```
RAM      : 2 GB+
CPU      : 2 cores+
Disk     : 30 GB+
Firmware : EFI enabled
```

Enable:

```
Settings
 → System
 → Enable EFI
```

---

# 📝 Notes

## Filesystem

Currently supports:

```
ext4
```

Future support planned:

```
btrfs
xfs
```

---

## UEFI Only

This installer requires:

```
/sys/firmware/efi/
```

Legacy BIOS systems are not supported currently.

---

## Home Partition Issue

If `/home` is missing from fstab:

Find UUID:

```bash
blkid
```

Add:

```
UUID=<uuid> /home ext4 defaults 0 2
```

---

# 🛠️ Development Status

Current:

```
Version: 1.0
Status : Stable
```

Implemented:

✅ Automated Arch installation
✅ UEFI support
✅ GRUB setup
✅ User creation
✅ Network setup
✅ Logging system

---

# 🗺️ Roadmap

Future improvements:

* [ ] Automatic partitioning option
* [ ] Desktop environment installer
* [ ] Backup and restore option
* [ ] Encryption support
* [ ] Better error recovery

---

# 🤝 Contributing

Contributions are welcome.

Steps:

```bash
git clone https://github.com/Abhishek3917/arch_linux_installation.git

cd arch_linux_installation
```

Create a branch:

```bash
git checkout -b feature-name
```

Commit:

```bash
git commit -m "add feature"
```

Push:

```bash
git push origin feature-name
```

Open a pull request.

---

# ❤️ Credits

Inspired by:

* Arch Linux Wiki
* Arch Linux Community
* Open-source Linux ecosystem

---
