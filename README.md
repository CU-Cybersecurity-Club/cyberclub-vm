# Base VM for the CU Boulder Cybersecurity club

This repo contains the Vagrantfile needed to build the cybersecurity club VM. The VM is the Kali vagrant VM with rootless docker installed. The VM provides some measure of isolation above and beyond docker, while docker provides a convenient way to deploy labs.

## Setup instructions
1. Install vagrant (https://www.vagrantup.com/downloads)
2. Navigate to this directory and run `vagrant up`
3. When prompted, enter in a new password for the vagrant user
4. After provisioning, connect to the box either through the opened VM GUI or through `vagrant ssh`

## Running labs
Labs are currently located at https://github.com/klinvill/cyberclub-labs. You can clone the labs from there and run them following the instructions in each lab.
