Linux kernel
============

This file was moved to Documentation/admin-guide/README.rst

Please notice that there are several guides for kernel developers and users.
These guides can be rendered in a number of formats, like HTML and PDF.

In order to build the documentation, use ``make htmldocs`` or
``make pdfdocs``.

There are various text files in the Documentation/ subdirectory,
several of them using the Restructured Text markup notation.
See Documentation/00-INDEX for a list of what is contained in each file.

Please read the Documentation/process/changes.rst file, as it contains the
requirements for building and running the kernel, and information about
the problems which may result by upgrading your kernel.

============

# POCO X3 NFC (Surya) Kernel – Balanced NetHunter

This repository is a fork of the original kernel source:
https://github.com/kylieeXD/android_kernel_xiaomi_surya

## Description
Modified Linux kernel (4.14) for **POCO X3 NFC (surya)**,  
designed with a **balance between battery efficiency and performance**,  
while adding support for **Kali NetHunter wireless features**.

This kernel is intended for users who want NetHunter capabilities
without sacrificing daily usability.

## Key Features
- Balanced performance and power consumption
- Monitor mode support
- Frame injection support
- External Wi-Fi adapter support

## Notable Changes
- Added Realtek **RTL8812AU** driver
- Enabled **ATH9K HTC** monitor & injection
- Patched **mac80211 / cfg80211** for NetHunter compatibility
- Clean commit separation for easier maintenance

## Patch Sources
Some patches were adapted and manually integrated from:
- Kali NetHunter kernel patches  
  https://gitlab.com/kalilinux/nethunter/build-scripts/kali-nethunter-kernel-builder

> Note: Build scripts are **not included** in this repository.

## Branches
- `SuperPotato` – NetHunter-patched kernel (balanced profile)

## Device Information
- Device: **POCO X3 NFC**
- Codename: **surya**
- Kernel version: **Linux 4.14**

## Notes
- This kernel aims to stay **stable for daily use**
- NetHunter features are provided without aggressive overclocking
- Use at your own risk

## Credits
- Original kernel source: kylieeXD
- Kali NetHunter team
- Community contributors

