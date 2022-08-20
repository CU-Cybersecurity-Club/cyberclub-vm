This directory contains scripts used to build a base kali box that works with the vmware_desktop provider.

Currently the kali vagrant boxes are only built for systems using the amd64 CPU architecture. This means that macs with a m1 chip (which is an arm64 architecture) cannot use the currently distributed kali boxes. This directory is meant to enable building of arm kali boxes that can run on the m1 chip (and therefore on new macs).

A packer file is included that should make it easier to build and package a base box. It is currently meant to be run along with an installation script, manual installation steps, and through a python script. Ideally this should be automated further. One of the key challenges to automation is the VMware fusion installation which includes setting up a license as part of it. Another challenge includes automating the mac provisioning and upload to vagrantcloud. It would be nice if we could use linux ARM images to do this more flexibly and cheaply (mac instances must be reserved for at least 24 hours on both Scaleway and AWS) but currently VMware has no type-2 hypervisor support for Linux (Fusion is only supported for macs and Workstation doesn't run on ARM machines).

## Current Steps to Build a Box (on an M1 Mac)
1. Install the VMware Fusion tech preview for ARM (or the main VMware Fusion release if it supports arm chips. The latest preview as of 8/18/2022 is: https://customerconnect.vmware.com/downloads/get-download?downloadGroup=FUS-PUBTP-22H2)
2. Run VMware Fusion so that you can go through the license setup.
3. Run the `install_requirements_mac.sh` script. It should prompt you for your password so it can run sudo commands.
4. Run the command `eval "$(/opt/homebrew/bin/brew shellenv)"` to be able to use the software brew downloaded in this current shell (if you open a new shell this command will already run automatically).
5. Run the `pack_latest_kali.py` script using python 3: `python3 pack_latest_kali.py`. The script will determine the latest kali ISO, start an http server to host the preseed configuration, and then run packer with the proper arguments to download the ISO, build the VM, and package it as a vagrant base box. The script can take in an optional argument specifying the architecture to build for (arm64 or amd64). The default is arm64.
6. (optional) Upload the new box to vagrant cloud: https://app.vagrantup.com/klinvill/boxes/kali_arm

## Testing the New Box
To test the box, you can follow the testing instructions at https://www.vagrantup.com/docs/boxes/base. If you want to launch the vm with a gui, make sure to enable that in the Vagrantfile.
