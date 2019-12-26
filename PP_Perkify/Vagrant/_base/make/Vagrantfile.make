# -*- mode: ruby -*-
# vi: set ft=ruby :

# This is `Vagrantfile.make`.  It specifies the provisioning and
# configuration of the base Perkify VM (before add_ons is run).

  Vagrant.configure('2') do |config|
    config.ssh.forward_x11  = true

    vm              = config.vm
    vm.box          = 'bento/ubuntu-19.04'
    vm.box_version  = '201906.18.0'

    # Create a forwarded port mapping which allows access to a specific port
    # within the machine from a port on the host machine and only allow access
    # via 127.0.0.1 to disable public access.

    vm.network  'forwarded_port',
      guest:    80,
      host:     8080,
      host_ip:  '127.0.0.1'

    # Provision and customize (see vf_common.rb).

    vm.provision :shell, inline: <<-SHELL
      set -ex
      hostname perkify-make
      apt-get update

      pkgs='debconf-utils ruby-full'
      for pkg in $pkgs; do
        apt-get install -y $pkg
      done
    SHELL

    prov_alsa(vm)     # Provision ALSA.

    cust_alsa(vm)     # Customize ALSA.
  end
