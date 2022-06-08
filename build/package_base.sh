#!/bin/bash
#
# Packs up a Kali vmware fusion vm for use as a vagrant base image. This should be run on the host machine after completing the vm setup (e.g. running setup_base.sh)

# Flags and helpers for better error handling
set -euo pipefail
trap 's=$?; echo >&2 "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR
IFS=$'\n\t'

# Optimize the box size by shrinking harddrives
VMWARE_FUSION_BIN="/Applications/VMWare Fusion.app/Contents/Library"
VM_LOCATION="${HOME}/Virtual Machines.localized/kali.vmwarevm"
"${VMWARE_FUSION_BIN}/vmware-vdiskmanager" -d "${VM_LOCATION}/Virtual Disk.vmdk"
"${VMWARE_FUSION_BIN}/vmware-vdiskmanager" -k "${VM_LOCATION}/Virtual Disk.vmdk"


cd "$VM_LOCATION"
# Create optional vagrant configuration files
echo '{"provider":"vmware_desktop"}' > metadata.json
cat <<-EOF > Vagrantfile
Vagrant.configure("2") do |config|
  config.vm.provider :vmware_desktop do |vmware|
    vmware.gui=true
    vmware.vmx["ide0:0.clientdevice"] = "FALSE"
    vmware.vmx["ide0:0.devicetype"] = "cdrom-raw"
    vmware.vmx["ide0:0.filename"] = "auto detect"
  end
end
EOF

# Package and compress the relevant files
tar cvzf kali_arm.box *.vmdk *.nvram *.vmsd *.vmx *.vmxf metadata.json Vagrantfile

# Move to home directory for easy extraction
mv kali_arm.box ~/
