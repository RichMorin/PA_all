# Make_Chef

[ This page is currently inactive, as we aren't using Chef yet... ]

The Make sub-project has a number of requirements:

+ a few dozen sets of `.../{main,make}.toml` files
- Elixir code (InfoMake) to generate a `docker.toml` file.
+ an installed, configured, and working copy of Chef
- an installed, configured, and working copy of Docker

## Installation

Download and install a DMG of Chef for macOS 10.13

Update `PATH` to include `/opt/chef-workstation/bin`.
(eg, edit /Local/Users/rdm/Dropbox/cfcl/stds/std.profile_rdm)

    $ mkdir cookbooks
    $ chef generate cookbook cookbooks/perkian
    Generating cookbook perkian
    - Ensuring correct cookbook file content
    - Ensuring delivery configuration
    - Ensuring correct delivery build cookbook content

    Your cookbook is ready. Type `cd cookbooks/perkian` to enter it.

    There are several commands you can run to get started locally
    developing and testing your cookbook.
    Type `delivery local --help` to see a full list.

    Why not start by writing a test? Tests for the default recipe
    are stored at:

    test/integration/default/default_test.rb

    If you'd prefer to dive right in, the default recipe can be found at:

    recipes/default.rb

Download the Docker Cookbook from
`https://supermarket.chef.io/cookbooks/docker#docker_installation`
and move it to the `cookbooks` directory.

Add `depends 'docker'` to `metadata.rb`.

Add sample code to `default.rb`:

    docker_service 'default' do
      action [:create, :start]
    end

    docker_image 'busybox' do
      action :pull
    end

    docker_container 'an-echo-server' do
      repo 'busybox'
      port '1234:1234'
      command "nc -ll -p 1234 -e /bin/cat"
    end

Try running the recipe:

    sudo chef-client --local-mode --override-runlist perkian




---

- Open Source Chef
  - https://www.chef.sh/about/
  - https://downloads.chef.io/chef-workstation/
  - https://downloads.chef.io/chef-workstation/#mac_os_x

- Chef Downloads
  https://www.chef.io/get-chef
  
  - Chef Workstation
    https://downloads.chef.io/chef-workstation/
  - Habitat CLI
  
## Docker

- Deploying docker containers with Chef
  https://linuxacademy.com/community/posts/show/topic/
    14088-deploying-docker-containers-with-chef

- Docker Cookbook
  https://github.com/chef-cookbooks/docker
  .../blob/master/libraries/docker_container.rb
  https://supermarket.chef.io/cookbooks/docker

- Docker Platform Cookbook
  https://gitlab.com/chef-platform/docker-platform

- Docker vs Chef
  https://www.upguard.com/articles/docker-chef

- Learning Docker - The Command Line Interface
  https://rangle.io/blog/learning-docker-command-line-interface

- Run bash or any command in a Docker container
  https://medium.com/the-code-review/
    run-bash-or-any-command-in-a-docker-container-9a1e7f0ec204

- Testing Chef Cookbooks with Kitchen and Docker
  https://linuxacademy.com/blog/devops/
    testing-chef-cookbooks-with-kitchen-and-docker/

- Use Chef
  https://docs.docker.com/v17.09/engine/admin/chef/

- Using Chef with Docker
  https://github.com/chef/community-summits/wiki/Using-Chef-with-Docker

- What does Docker add to lxc-tools (the userspace LXC tools)?
  https://stackoverflow.com/questions/17989306/
    what-does-docker-add-to-lxc-tools-the-userspace-lxc-tools


## Puppet

- https://puppet.com
