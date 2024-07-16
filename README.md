# Arch Linux Installation Script

This script automates the Arch Linux installation process, focusing on systems booted in UEFI mode. It guides the user through essential steps such as partitioning, filesystem creation, package installation, and basic system configuration.

## Security Disclaimer

This script is for educational purposes only. It is not intended for use in a production environment without proper security hardening specific to that environment. Running user-provided scripts can be risky. Always review and understand the script before running it on your system.

## Features

- UEFI mode detection and compatibility.
- User-friendly prompts for essential information (EFI partition, root partition, etc.).
- Automatic filesystem creation and mounting.
- Base system and essential packages installation.
- Timezone and localization configuration.
- Hostname and user account setup.
- GRUB bootloader installation and configuration.
- NetworkManager activation.

## Getting Started

1. **Boot into Arch Linux Installation Media:**
    - Create a bootable USB or CD with the Arch Linux installation image.
    - Boot your system from the installation media.

2. **Identify Disk Partitions:**
    - Run `fdisk -l` to list available disk partitions.
    - Identify the target disk for installation (e.g., /dev/sdX).

3. **Create Partitions:**
    - Use a partitioning tool (e.g., cfdisk, fdisk, parted) to create partitions on the target disk.
    - Note the partition names for EFI, root, home, and swap.

4. **Download the Script:**
    ```bash
    curl https://raw.githubusercontent.com/Abhishek3917/arch_linux_installation/main/arch_install.sh -o arch_install.sh
    ```

5. **Run the Script:**
    ```bash
    sh arch_install.sh
    ```

6. **Follow the Prompts:**
    - Respond to the prompts to provide necessary information for the installation.

7. **Post-Installation:**
    - After the base installation is complete, follow the instructions to reboot.
    - Optionally, clone post-installation scripts and execute them as directed.

## Post-Installation

- this script is in its development stage 

## Notes

- This script assumes a basic level of familiarity with the Arch Linux installation process.
- Customize the script according to your preferences and requirements.
- Timezone set default to Asia/Kolkata.
- Check `/mnt/etc/fstab` if the home partition is not present. Add manually by:
    ```bash
    blkid /home_partition
    ```
- Add a line for the home partition using the UUID you obtained in the previous step. The line should look something like this:
    ```bash
    UUID=<home_partition_UUID> /home ext4 defaults 0 2
    ```
- Save and Exit.
