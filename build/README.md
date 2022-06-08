This directory contains scripts used to build a base kali box that works with the vmware_desktop provider.

Currently the kali vagrant boxes are only built for systems using the amd64 CPU architecture. This means that macs with a m1 chip (which is an arm64 architecture) cannot use the currently distributed kali boxes. This directory is meant to enable building of arm kali boxes that can run on the m1 chip (and therefore on new macs).

The scripts are currently executed manually but should be used alongside [packer](https://www.packer.io) to automate the box generation if we continue to use these boxes. The [vmware builder](https://www.packer.io/plugins/builders/vmware) and [vagrant post-processor](https://www.packer.io/plugins/post-processors/vagrant/vagrant) would likely be required when using packer.
