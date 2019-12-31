<!-- Perkify_Install/common_1.md -->

### Directory Setup

*Note:*
We can't predict your host machine's prompt string,
so we'll just use the string `Host:` below.

In a Terminal window, enter the following commands:

    Host: cd                                # go to your home directory
    Host: mkdir V_perkify                   # create a working directory
    Host: cd V_perkify                      # go to the working directory
    Host: vagrant init Rich_Morin/Perkify   # initialize the directory

Like many Vagrant commands, this will output a slew of messages.
I've submitted an [issue]{ext_gh|hashicorp/vagrant/issues/11037},
asking for a "quiet" mode (e.g., `--quiet`).
This enhancement request has been added to Vagrant's
[2.2 milestone]{ext_gh|hashicorp/vagrant/milestone/35},
but no schedule has been provided.
So, until this feature becomes available,
you'll just have to endure the chatter.
