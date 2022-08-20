# Base VM for the CU Boulder Cybersecurity club

This repo contains the Vagrantfile needed to build the cybersecurity club VM. The VM is the Kali vagrant VM with rootless docker installed. The VM provides some measure of isolation above and beyond docker, while docker provides a convenient way to deploy labs.

## Setup instructions
1. Install vagrant (https://www.vagrantup.com/downloads)
2. Navigate to this directory and run `vagrant up`
3. When prompted, enter in a new password for the vagrant user
4. After provisioning, connect to the box either through the opened VM GUI or through `vagrant ssh`

## Running labs
Labs are currently located at https://github.com/klinvill/cyberclub-labs. You can clone the labs from there and run them following the instructions in each lab.

## Note on ARM platforms (e.g. M1 Macs)
We have attempted to provide out-of-the-box support for M1 macs by pointing to an ARM Kali box if the machine is detected to have an ARM architecture or to be running Rosetta (translation for x64 executables). In this case, you will need to run the VM using the VMWare Fusion tech preview (one of the few hypervisors that currently runs on M1 Macs to our knowledge). The instructions at this gist (up through "Installing Vagrant VMWare provider"): https://gist.github.com/sbailliez/f22db6434ac84eccb6d3c8833c85ad92 worked on 6/8/2022. The latest link to the ARM tech preview as of 8/18/2022 is https://customerconnect.vmware.com/downloads/get-download?downloadGroup=FUS-PUBTP-22H2. You may have to google around to find the latest tech preview (or hopefully simply find that arm support has been added to the main VMWare Fusion product).

Specifically, the additional steps for a M1 or M2 mac are:
1. Install Rosetta: `/usr/sbin/softwareupdate --install-rosetta --agree-to-license`
2. Install Vagrant if not already installed (https://www.vagrantup.com/downloads)
3. Download the VMware Fusion Tech Preview (https://customerconnect.vmware.com/downloads/get-download?downloadGroup=FUS-PUBTP-22H2)
4. Launch the VMWare Fusion Tech Preview application and go through license steps (should have a free license)
5. Create a symbolic link to the tech preview so it works with vagrant like a normal installation: `ln -s '/Applications/VMWare Fusion Tech Preview.app' '/Applications/VMWare Fusion.app'`
6. Install the Vagrant VMware provider (https://www.vagrantup.com/vmware/downloads)
7. Install the Vagrant VMware plugin: `vagrant plugin install vagrant-vmware-desktop`
8. Follow the rest of the setup instructions as normal (described above)

## Reporting Problems
Please let us know (either through a club channel or a GitHub issue) if you run into problems getting the club VM setup. Include a description of any error messages and erroneous behavior, as well as a description of your machine so we can try and reproduce the error.
