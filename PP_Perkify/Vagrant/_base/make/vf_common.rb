
# vf_common.rb - common Ruby code for use in Vagrantfiles
#
# This file is appended to Vagrantfile.* by mpma, making its routines
# available to their Ruby code.  This hack avoids problems of the files
# becoming separated and thus unavailable to the load command, etc.
#
# conf_ports(vm)            Configure forwarded port mappings.
# cust_alsa(vm)             Customize the VM's audio settings.
# prov_init(vm, hostname)   Perform initial provisioning
#
# See also:
#
#   https://www.vagrantup.com/docs/provisioning/basic_usage.html
#
# Written by Rich Morin, CFCL, 2019-2020.

  def conf_ports(vm)
  #
  # Configure forwarded port mappings from the guest (VM) to the host.
  #
  # In general, mappings should only allow access to a specific port within
  # the guest (VM) via a port on the host machine.  So, we use an IP address
  # of 127.0.0.1 to disable public access.

    mappings = {
    # guest     host
      80     => 8080,   # basic HTTP
    }

    mappings.each do |guest, host|
      vm.network('forwarded_port',
        guest:    guest,
        host:     host,
        host_ip:  '127.0.0.1'
      )
    end
  end


  def cust_alsa(vm)
  #
  # Customize the VM's audio settings, based on the host's operating system.
  #
  # For details, see:
  #   https://www.vagrantup.com/docs/virtualbox/configuration.html
  #     #vboxmanage-customizations

    vm.provider :virtualbox do |vb|
      audio = case RUBY_PLATFORM
        when /darwin|mac os/;                             'coreaudio'
        when /bccwin|cygwin|emc|mingw|mswin|msys|wince/;  'dsound'
        when /linux/;                                     'alsa'
      end

      vb.customize [ 'modifyvm',  :id,
        '--audio',                audio,
        '--audiocontroller',      'hda',
        '--audioout',             'on'
      ]
    end
  end


  def prov_init(vm, hostname)
  #
  # Perform initial provisioning

    build = <<-SHELL
    # set -ex #!T

      hostname #{ hostname }
    SHELL

    vm.provision(:shell, inline: build)
  end
