
# vf_common.rb - common Ruby code for use in Vagrantfiles
#
# This file is appended to Vagrantfile.* by mpma, making its routines
# available to their Ruby code.  This hack avoids problems of the files
# becoming separated and thus unavailable to the load command, etc.
#
# Written by Rich Morin, CFCL, 2019.

  def cust_alsa(vm)
  #
  # Customize the VM's audio settings, based on the host's operating system.

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

  def prov_alsa(vm)
  #
  # provisioning script for ALSA
  #
  # This code is adapted from Christoph Neumann's vagrant-audio Vagrantfile
  # (in https://github.com/christoph-neumann/vagrant-audio), with help from
  # Clemens Ladisch and Eric Zuck.  See also `./cust_alsa.rb`.
  #
  # For details, see:
  #   https://www.virtualbox.org/manual/ch08.html#vboxmanage-modifyvm-general
  #   https://www.vagrantup.com/docs/virtualbox/configuration.html
  #     #vboxmanage-customizations

    vm.provision "shell", inline: <<SHELL
extra=linux-modules-extra-$(uname -r)
echo "extra: $extra" #!T
apt-get install -y linux-image-generic $extra alsa-utils

sudo usermod -aG audio vagrant

cat <<CONF > /etc/asound.conf
pcm.!default {
  type plug
  slave.pcm "hw:0,1"
}
CONF

sudo modprobe snd
sudo modprobe snd-hda-intel
sleep 2
sudo amixer -c 0 set Master playback 100% unmute
SHELL
  end

  def prov_apache(vm)
  #
  # provisioning script for Apache

    vm.provision "shell", inline: <<SHELL
apt-get install -y apache2

src=/var/www/html
tgt=/home/vagrant/_base/html
rm -rf $src
ln -fs $tgt $src
SHELL
  end
