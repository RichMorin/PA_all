### Implementation

#### Is Perkify entirely open source?

Basing Perkify entirely on open source software
allows us to redistribute it freely (*gratis* and *libre*).
That is, we don't charge for it and we don't add any restrictions.
However, we are open to supporting proprietary add-on software
that is particularly popular and/or useful.
Feel free to contact us with questions, suggestions, etc.
 
#### Why does Perkify use Vagrant?

There are several things we like about Vagrant:

- It allows the VM to be used and administered entirely
  from the command line, which is great for blind users.

- It allows the possibility of supporting multiple "providers".
  At the moment, we're only using [VirtualBox]{ext_wp|VirtualBox},
  but [Docker]{ext_wp|Docker_(software)} and "custom" providers
  such as [QEMU]{ext_wp|QEMU} and [VMware]{ext_wp|VMware} 
  may also be of interest at some point.
  
- It's written in [Ruby]{ext_wp|Ruby_(programming_language)},
  making it comfortable for us to work with and extend.

[virt-manager]{https://virt-manager.org} appears
to offer a similar set of management capabilities,
albeit for a somewhat different set of VMs:
"[It] primarily targets KVM VMs,
but also manages Xen and LXC (linux containers)".
However, it only supports Linux as a host platform.

#### Why does Perkify use VirtualBox?

[VirtualBox]{ext_wp|VirtualBox} meets our major criteria
(e.g., licensing, portability) for infrastructure.
That said, it's far from perfect (e.g., high latency audio).
Here are some brief notes on alternative approaches;
additions, comments, and corrections are welcome!

- [Docker]{ext_wp|Docker} requires that the container be running
  the same kernel as the host platform,
  so it can't provide a cross-platform solution.

- [Hyper-V]{ext_wp|Hyper-V},
  [Parallels]{ext_wp|Parallels_Desktop_for_Mac}, and
  [VMware]{ext_wp|VMware#Desktop_software} aren't options
  for our primary platform, because they're proprietary.
  Also, Hyper-V isn't intended for use on desktop machines
  and Parallels only runs on macOS.

- [KVM]{ext_wp|Kernel-based_Virtual_Machine} and
  [QEMU]{ext_wp|QEMU} are open source, but they only run on Linux.
