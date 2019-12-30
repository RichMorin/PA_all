<!-- Perkify_Install/common_2.md -->

The `vagrant init` command will add a `.vagrant.d` sub-directory
in your home directory;
Vagrant will use this for support code and machine image files.
In general, you should leave this directory alone,
but feel free to inspect it and see what it contains.

It will also add a generic version of the
<code>[Vagrantfile]{https://www.vagrantup.com/docs/vagrantfile}</code>,
which will contain configuration information for the virtual machine.
This would be a good time to skim the `Vagrantfile`,
in order to get an idea of the possible options.

*Note:*
Don't modify this copy of the `Vagrantfile`,
lest your changes cause problems or get overwritten by an update.
If need be, you can augment (or even override) its settings.
For details, see [Perkify - Configuration]{con_how|Perkify_Config}.
