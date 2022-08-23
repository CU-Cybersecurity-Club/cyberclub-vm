# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  is_arm = begin
    # If vagrant is being run using rosetta (internally named oahd) which seamlessly runs some x64 executables on m1 macs, then we know we're on an arm platform
    (RUBY_PLATFORM.include? 'arm') || (`pgrep oahd` != "")
  rescue Errno::environment
    # Couldn't find pgrep executable, assume it's not arm
    false
  end

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  if is_arm
    config.vm.box = "klinvill/kali_arm"
  else
    config.vm.box = "kalilinux/rolling"
    # There's an error in v2022.3.1 and v2022.3.2 that prevents these boxes from working normally. Avoid those boxes until the issue can be fixed.
    config.vm.box_version = "< 2022.3.0"
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # Disable default shared folder
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
 
  # Default values to use for all provisioners
  memory = "4096"
  name = "CyberClub Base VM"

  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vb|
    # Display the VirtualBox GUI when booting the machine
    vb.gui = true
 
    # Customize the amount of memory on the VM:
    vb.memory = memory

    # Customize the VM name:
    vb.name = name
  end

  config.vm.provider "vmware_desktop" do |vm|
    vm.gui = true
    vm.vmx["memsize"] = memory
    vm.vmx["displayName"] = name
  end

  config.vm.provider "hyperv" do |hv|
    hv.memory = memory
    hv.vmname = name
  end

  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Gets new password from user
  class Password
    def to_s
      init = true
      begin
        if !init 
            puts "Passwords don't match, try again." 
        else
            init = false
        end
        p1 = STDIN.getpass('Enter new password: ')
        p2 = STDIN.getpass('Re-enter the same password: ')
      end while p1 != p2
      p1
    end
  end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", env: {"PASSWORD" => Password.new}, inline: <<-SHELL
    C_RST="\e[0m"       # reset
    C_WARN="\e[33m"     # yellow (warning color)
    function warn {
        echo -e "${C_WARN}" "$@" "${C_RST}"
    }

    # Change default host ssh keys
    rm /etc/ssh/ssh_host_*
    dpkg-reconfigure openssh-server
    systemctl restart ssh
    warn 'SSH host keys have been changed from the insecure default, you may need to update your ~/.ssh/known_hosts file and remove the [localhost]:2222 entries to avoid unknown host errors.'

    # Change default password
    echo "vagrant:${PASSWORD}" | chpasswd
    unset PASSWORD

    # debconf is set with a non-existent drive for grub. When grub needs to be upgraded, this causes the script to hang. We instead try to pre-empt that by setting debconf to answer with the appropriate device here.
    echo "set grub-pc/install_devices /dev/sda" | sudo debconf-communicate
    # Good practice to patch when you can
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

    # Install docker
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    DEB_RELEASE="bullseye"
    warn "Assuming latest stable Debian release is ${DEB_RELEASE}. Since Kali is a rolling release based off Debian's testing release, there's no good way to determine this dynamically. Change the release in the Vagrantfile as needed."
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian ${DEB_RELEASE} stable" | tee /etc/apt/sources.list.d/docker.list > /dev/nul
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    # Install dependencies for rootless docker
    apt-get install -y uidmap fuse-overlayfs
    # Disable system-wide docker daemon
    systemctl disable --now docker.service docker.socket
    systemctl stop docker.service docker.socket
    # Install rootless docker as user
    su vagrant -c '/usr/bin/dockerd-rootless-setuptool.sh install'
    # Set rootless docker to be used by default
    su vagrant -c 'systemctl --user enable docker'
    su vagrant -c 'systemctl --user start docker'
    loginctl enable-linger vagrant
    su vagrant -c 'echo "docker context use rootless" >> ~/.zshrc'
    # Test installation
    su vagrant -c 'source ~/.zshrc && docker run --rm hello-world'

    # Require password to use sudo. Note: this needs to come at the end of provisioning since vagrant relies on sudo for commands.
    sed -i 's/NOPASSWD/PASSWD/' /etc/sudoers.d/vagrant
  SHELL
end
