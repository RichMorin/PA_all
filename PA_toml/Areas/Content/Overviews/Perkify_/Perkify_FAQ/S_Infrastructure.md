### Infrastructure

#### Why is all of Perkify's infrastructure [open source]{ext_wp|Open_source}?

Basing Perkify entirely on open source software
allows us to redistribute it freely (*gratis* and *libre*).
That is, we don't charge for it and we don't add any restrictions to its use.

#### Why are you using Vagrant?

There are several things to like about Vagrant:

- It allows the VM to be used and administered entirely
  from the command line, which is great for blind users.

- It allows the possibility of supporting multiple "providers".
  At the moment, we're only using [VirtualBox]{ext_wp|VirtualBox},
  but [Docker]{ext_wp|Docker_(software)} and "custom" providers
  such as [QEMU]{ext_wp|QEMU} and [VMware]{ext_wp|VMware} 
  may also be of interest at some point.
  
- It's written in [Ruby]{ext_wp|Ruby_(programming_language)},
  making it comfortable to work with and extend.

#### Why are you using VirtualBox?

- [Docker]{ext_wp|Docker} requires that the container be running
  the same kernel as the host platform, so it can't be cross-platform.

- [Hyper-V]{ext_wp|Hyper-V},
  [Parallels]{ext_wp|Parallels_Desktop_for_Mac}, and
  [VMware]{ext_wp|VMware#Desktop_software} aren't options
  for our primary platform, because they're proprietary.
  Also, Hyper-V isn't intended for use on desktop machines
  and Parallels only runs on macOS.

- [QEMU]{ext_wp|QEMU} is open source and has cross-platform support,
  but it isn't (yet) supported by Vagrant.

In short, [VirtualBox]{ext_wp|VirtualBox} seems to check off most
of our wish list items, even though it's far from perfect
(e.g., high latency audio).
