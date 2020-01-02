<!-- Perkify_Install/common_3.md -->

### Installation

We're (finally) ready to run the `vagrant up` command.  This will:

- download the Perkify "box" from the Vagrant Cloud
- boot the Perkify virtual machine ([VM]{ext_wp|Virtual_machine})
- start up background tasks (e.g., a web server)

Because the Perkify box is several gigabytes in size,
the initial download may take a while (e.g., an hour).
You might want to estimate the amount of time this will take.
If you don't know how fast your connection is,
run a [speed test]{https://www.speedtest.net}.
If your [download]{ext_wp|Download} speed is 20 Mbps, downloading
a 10 GB (80 Gb) of image data will take about an hour (4000 seconds).

As a side note, Perkify includes a copy of the
[Interactive Ruby Shell]{ext_wp|Interactive_Ruby_Shell};
here's how this calculation might be done in `irb(1)`:

    irb(main):001:0> secs = ( (80 * 1000) / 20) 
    => 4000
    irb(main):002:0> secs / 3600.0
    => 1.1111111111111112
    irb(main):003:0> exit

In any event, you can now ask Vagrant to start up a virtual machine.
Eventually, the command should finish,
leaving you back at a command line prompt on the host machine:

    Host: vagrant up
    ...
    Host:

### Example Commands

*Note:*
The Perkify VM runs Ubuntu Linux (regardless of the OS on your host system),
so you may have to learn some new ways of doing things.
If you're used to macOS (or some other Linux variant),
be prepared for minor differences in command options.

Let's try out some example commands.
Use Vagrant to connect to the VM via Secure Shell ([SSH]{ext_wp|Secure_Shell}),
then inspect the running system:

    Host: vagrant ssh               # Connect to the VM via SSH.
    Welcome to Ubuntu 19.04 (GNU/Linux 5.0.0-17-generic x86_64)
    ...

    vagrant@perkify:~$ pwd          # Print the "working directory".
    /home/vagrant

    vagrant@perkify:~$ l            # What's in this directory?
    _base/  _sync/  bin/

    vagrant@perkify:~$ df -k        # Show some file system information.
    Filesystem  1K-blocks      Used  Available Use% Mounted on
    udev           467888         0     467888   0% /dev
    ...

    vagrant@perkify:~$ uname -v     # Describe the VM's kernel version.
    #40-Ubuntu SMP ...

    vagrant@perkify:~$ exit         # Terminate the SSH session.
    logout
    Connection to 127.0.0.1 closed.

    Host: uname -v                  # Describe the host's kernel version.
    ...

At this point, the Perkify VM is still running.
So, you can run `vagrant ssh` again whenever you wish.
Indeed, you can have multiple SSH sessions going at the same time.
However, if you're done with the VM for the moment,
there are various ways to shut it down.
Normally, you'll want to use `vagrant suspend`:

- `vagrant destroy`   - halt the VM, removing all traces
- `vagrant halt`      - halt the VM; don't save the state
- `vagrant suspend`   - suspend the VM, saving the state

Because Vagrant has now downloaded the Perkify files,
starting up the VM will now be somewhat faster.
However, loading the machine image into memory and booting Ubuntu
will still take a couple of minutes.

    Host: cd ~/V_perkify
    Host: vagrant up
    ...

    Host: vagrant ssh
    ...

    vagrant@perkify:~$ 

### Sanity Check

Because Perkify is very raw tchnology, it's quite possible that parts of it
will be broken in one way or another.
So, if you have some time and disk space to spare,
you might want to install a "vanilla" Ubuntu VM for purposes of comparison.
Here are some commands that should work:

    Host: cd                                # go to your home directory
    Host: mkdir V_ubuntu                    # create a working directory
    Host: cd V_ubuntu                       # go to the working directory
    Host: vagrant init bento/ubuntu-18.10   # initialize the directory
    Host: vagrant up                        # download and install the VM
    Host: vagrant ssh                       # start up an SSH session

### Discussion

There really aren't many Vagrant commands that you'll use regularly.
Mostly, you'll be interacting with [Bash]{ext_wp|Bash_(Unix_shell)},
the Linux "shell".
That said, there are several commands you'll need to know about.
So, let's move on to the [Perkify - Usage]{con_how|Perkify_Usage} page.
