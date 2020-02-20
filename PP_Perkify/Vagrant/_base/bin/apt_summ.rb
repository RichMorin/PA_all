#!/usr/bin/env ruby
#
# apt_summ.rb - display a summary of installed APT packages
#
# This version is inactive, because Ruby isn't included in Ubuntu by default.
# See apt_summ for the active (Perl 5) version.
#
# Written by Rich Morin, CFCL, 2019

  Signal.trap('PIPE', 'EXIT')

  lines  = `dpkg -l`.split("\n")
  # ii  gnome  1:3.30+1ubuntu1  amd64  Full GNOME Desktop Environment, ...

  patt   = /^....(\S+)\s+(\S+)\s+(\S+)\s+(.*)$/

  lines.each do |line|
    next if line =~ /^\|\|/

    patt.match(line) do |m|
      puts "#{ m[1] } (#{ m[2]}) - #{ m[4] }"
    end
  end 
