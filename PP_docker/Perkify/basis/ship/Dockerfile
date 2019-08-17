# Dockerfile
#
# See:
#   https://hub.docker.com/_/debian
#   https://docs.docker.com/get-started/part2/
#
# Written by Rich Morin, CFCL, 2019.

# Debian Buster, released as stable in July 2019, is now debian:latest.

FROM      mpi
RUN       useradd -m me
USER      me
WORKDIR   /home/me
RUN echo 'export PS1="\u@perk:\w\$ "' >> /home/me/.bashrc

