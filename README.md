# Arch Linux Installation Script

This script automates the installation of base Arch Linux on systems booted in UEFI mode. It simplifies the installation process by handling partitioning, formatting, package installation, and basic system configuration.

## Security Disclaimer

Always review and understand the script before executing it on your system.

## Prerequisites

1. **Boot into Arch Linux Installation Media:**
    - Create a bootable USB or CD with the Arch Linux installation image.
    - Boot your system from the installation media.

2. **Identify Disk Partitions:**
    - Run `fdisk -l` to list available disk partitions.
    - Identify the target disk for installation (e.g., /dev/sdX). 

3. **Create Partitions:**
    - Use a partitioning tool (e.g., cfdisk, fdisk, parted) to create partitions on the target disk.
    - Example: Use fdisk /dev/sdX for creating partitions.
    - Note the partition names for EFI, root, home, and swap (optional).

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
### Partitioning and Formatting
- The script assumes that all partitions, including root and home, use the ext4 filesystem format.
### UEFI Systems Only
- This script is designed for systems booted in UEFI mode. If using a non-UEFI (BIOS/MBR) system, modifications to the GRUB installation process are required. Refer to the [Arch Linux GRUB documentation for instructions](https://wiki.archlinux.org/title/GRUB#Master_Boot_Record_(MBR)_specific_instructions).
- The script automatically detects and sets the system timezone using curl and ipapi.co..
- verify `/mnt/etc/fstab` if the home partition is not present. Add manually by:
    ```bash
    blkid /home_partition
    ```
- Add a line for the home partition using the UUID you obtained in the previous step. The line should look something like this:
    ```bash
    UUID=<home_partition_UUID> /home ext4 defaults 0 2
    ```
- Save and Exit.
## Post-Installation
### Reboot the System
- After the installation is complete, reboot the system
### Optional Post-Installation Script:
- If you chose to clone the post-installation script, it will be available in the home directory of the newly created user.
- Execute the script to install additional packages and configure the system further

## Development Status

```The arch_install.sh script has been updated and is now stable. However, the post-installation script is still in development. Contributions and feedback are welcome! Please report any issues or suggest improvements by opening an issue on the GitHub repository.```
## Acknowledgments
- Inspired by the official [Arch Linux Installation Guide](https://wiki.archlinux.org/title/Installation_guide).
- Thanks to the Arch Linux community for their extensive documentation and support.
