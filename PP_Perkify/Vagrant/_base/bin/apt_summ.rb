#!/usr/bin/env ruby
#
# apt_summ - display a summary of installed APT packages
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
