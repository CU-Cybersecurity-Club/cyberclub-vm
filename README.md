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
We have attempted to provide out-of-the-box support for M1 macs by pointing to an ARM Kali box if the machine is detected to have an ARM architecture or to be running Rosetta (translation for x64 executables). Please let us know (either through a club channel or a GitHub issue) if you run into problems getting the club VM setup. Include a description of any error messages and erroneous behavior, as well as a description of your machine so we can try and reproduce the error.
