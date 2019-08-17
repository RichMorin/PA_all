# Make_Base

These notes describe the setup of the Perkian base build environment on Fido.

## Stack

- macOS 10.13.6
- VirtualBox 6.0.10
- Ubuntu Desktop 19.04
- Docker Engine
- Debian Container

## Installation

Download and install the VirtualBox base package:

- Browse to `https://www.virtualbox.org/wiki/Downloads`.
- Download the DMG file for the VirtualBox base package.
- Run the VirtualBox installer.
- Create `.../Applications/VirtualBox` for miscellaneous files.
- Copy in `UserManual.pdf` and `VirtualBox_Uninstall.tool`.

Download the ISO file for Ubuntu Desktop: 

- Browse to `https://ubuntu.com/download/desktop`.
- Download the ISO file as `~/VirtualBox VMs/ubuntu-19.04-desktop-amd64.iso`.

Create a virtual machine for Ubuntu:

- Click New in the VirtualBox Manager.
- In the "Create Virtual Machine" sheet, specify:
  - Name:             Ubuntu_19_04_b
  - Machine Folder:   /Users/rdm/VirtualBox VMs
  - Type:             Linux
  - Version:          Ubuntu (64-bit)
- Specify 8192 MB for the memory size.
- Specify 50 GB for the hard disk size.

Start the Ubuntu virtual machine and install Ubuntu:

- Specify `~/VirtualBox VMs/ubuntu-19.04-desktop-amd64.iso`.
- your name:          Rich Morin
- computer name:      make
- username:           rdm
- select "log in automatically"

## Customization

### APT Add-ons

    sudo apt install net-tools          # ifconfig, etc.
    sudo apt install openssh-server     # SSH server
    
### Display Size

The default display size is 800x600 pixels.  To expand this to match the Dell
monitor:

- Click the Activities menu item.
- Enter "Displays".
- Select Displays (within Settings).
- Set Resolution to "1920 x 1440 (4:3)".

### Lock Screen

Ubuntu starts with a lock screen.  Dragging this up reveals a login window.
After logging in, you get a user window with dockish icons, etc.  To disable
the lock screen:

- Click the Activities menu item.
- Enter "Privacy".
- Select Privacy (within Settings).
- Set "Automatic Screen Lock" to "Off".

### Incoming SSH

To set up incoming SSH on Ubuntu:

- Click Settings in the VirtualBox Manager.
- Select "Bridged Adapter".
- In an Ubuntu terminal, run ifconfig and get the IP address (eg, 192.168.1.134).

## Usage

### Copy/Paste

- Ctrl+Shift+C copies
- Ctrl+Shift+V pastes

### SSH

    ssh rdm@192.168.1.134

### Terminal

- Click the Activities menu item.
- Enter "Terminal".


Q: How do we set up a fixed IP address on the LAN and a hostname (eg, make)?
