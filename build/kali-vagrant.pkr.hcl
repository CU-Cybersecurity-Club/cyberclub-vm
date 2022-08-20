packer {
  required_plugins {
    vmware = {
      version = ">= 1.0.3"
      source = "github.com/hashicorp/vmware"
    }
  }
}

variable "kali_iso_url" {
  type = string
  description = "The url to the desired Kali ISO to build."

  validation {
    condition = length(var.kali_iso_url) > 8 && substr(var.kali_iso_url, 0, 8) == "https://"
    error_message = "The url must be an https url."
  }
}

variable "kali_iso_checksum" {
  type = string
  description = "The checksum of the desired Kali ISO to build."
}

variable "preseed_host" {
  type = string
  description = "The ip address or hostname where the kali-preseed.cfg file is hosted."
}

variable "preseed_port" {
  type = number
  description = "The port where the kali-preseed.cfg file is hosted."
}

variable "arch" {
  type = string
  description = "The architecture to build a vm for (arm64 or amd64)."
  validation {
    condition = length(var.arch) == 5 && (substr(var.arch, 0, 5) == "arm64" || substr(var.arch, 0, 5) == "amd64")
    error_message = "The architecture must either be arm64 or amd64."
  }
}

source "vmware-iso" "kali-vagrant-amd64" {
  guest_os_type = "debian10-64"
  iso_url = var.kali_iso_url
  iso_checksum = var.kali_iso_checksum
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout = "60m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  http_directory = "http"
  cpus = 2
  memory = 2048
  network = "nat"
  network_adapter_type = "vmxnet3"
  vmx_data_post = {
    "ide0:0.startConnected" = "FALSE"
    "ide0:0.deviceType" = "cdrom-raw"
    "ide0:0.clientDevice" = "TRUE"
    "ide0:0.present" = "FALSE"
    "ide0:0.fileName" = "emptyBackingString"
  }
  // Note: boot_command derived from https://gitlab.com/kalilinux/build-scripts/kali-vagrant/-/blob/master/config.json
  boot_command = [
    "<esc><wait>",
    "install <wait>",
    // Note: when running this on my mac and using packer to host the preseed file over http, the installation hangs early on with an empty blue screen. However, the installation succeeds when I host the file myself. You may need to host the file yourself to get this to work.
    // "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kali-preseed.cfg ",
    "preseed/url=http://${ var.preseed_host }:${ var.preseed_port }/kali-preseed.cfg ",
    "locale=en_US ",
    "keymap=us ",
    "hostname=kali ",
    "domain='' ",
    "<enter>"
  ]
}

source "vmware-iso" "kali-vagrant-arm64" {
  version = "19"
  disk_adapter_type = "nvme"
  network_adapter_type = "e1000e"
  usb = "true"
  guest_os_type = "arm-debian12-64"
  iso_url = var.kali_iso_url
  iso_checksum = var.kali_iso_checksum
  ssh_username = "vagrant"
  ssh_password = "vagrant"
  ssh_timeout = "60m"
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"
  http_directory = "http"
  cpus = 2
  memory = 2048
  network = "nat"
  vmx_data = {
    "architecture" = "arm64"
    "usb_xhci.present" = "true"
  }
  vmx_data_post = {
    "ide0:0.startConnected" = "FALSE"
    "ide0:0.deviceType" = "cdrom-raw"
    "ide0:0.clientDevice" = "TRUE"
    "ide0:0.present" = "FALSE"
    "ide0:0.fileName" = "emptyBackingString"
  }
  // Note: boot_command derived from https://gitlab.com/kalilinux/build-scripts/kali-vagrant/-/blob/master/config.json
  boot_command = [
    "c<wait>",
    "linux /install.a64/vmlinuz ",
    "install ",
    "auto ",
    // Note: when running this on my mac and using packer to host the preseed file over http, the installation hangs early on with an empty blue screen. However, the installation succeeds when I host the file myself. You may need to host the file yourself to get this to work.
    // "url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/kali-preseed.cfg ",
    "preseed/url=http://${ var.preseed_host }:${ var.preseed_port }/kali-preseed.cfg ",
    "locale=en_US ",
    "keymap=us ",
    "hostname=kali ",
    "domain='' ",
    "---",
    "<enter><wait>",
    "initrd /install.a64/initrd.gz",
    "<enter><wait>",
    "boot",
    "<enter><wait>",
  ]
}

build {
  sources = ["sources.vmware-iso.kali-vagrant-${ var.arch }"]

  provisioner "shell" {
    script = "setup_base.sh"
  }

  post-processor "vagrant" {}
}
