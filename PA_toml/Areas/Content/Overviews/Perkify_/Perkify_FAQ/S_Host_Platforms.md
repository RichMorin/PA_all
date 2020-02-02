### Host Platforms

#### What host platforms are supported?

Because Perkify is based on Vagrant,
it only supports Linux, macOS, and Windows as host operating systems.
And, because it is based on VirtualBox,
the host hardware needs to have a 64-bit AMD or Intel CPU.
Of course, it may be possible to relax these restrictions in the future.

#### What does Perkify add to Linux?

Someone who uses Linux regularly may see little reason to use Perkify.
However, an Arch Linux user might not have a convenient way
to install some of the packages that Perkify contains.
So, it can be useful to have a turnkey VM on hand,
if only as a way to (conveniently and safely) try out packages.

#### What does Perkify add to macOS?

Because macOS is based on a Unix variant (FreeBSD),
many open source packages are able to run on it.
However, there are several package management systems for macOS
(e.g., Fink, Homebrew, MacPorts).
Some of these may support a desired package; other may not.
Worse, they can get in each other's way.

#### What does Perkify add to Windows?

Historically, relatively few open source packages
have available for Microsoft Windows.
However, recent versions of Windows include
Windows Subsystem for Linux (WSL), which is based on Ubuntu Linux.
In theory, WSL can install all of the same packages that Perkify can.
So, the main advantages of Perkify on these systems
have to do with the fact that it is an isolated, turnkey way
to use open source software.
