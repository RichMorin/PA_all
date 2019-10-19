#!/usr/bin/env ruby
#
#  add_ons.rb - Ruby-based helper for the add_ons script
#
# Written by Rich Morin, CFCL, 2019.

  require 'fileutils'
  require 'toml-rb'

  def main()
    log_dir     = ARGV[0]

    fmt_1       = '%-12s  %s'
    fmt_2       = "%s  %7.1f  %4d\n\n"

    info_pkgs   = {}
    toml_path   = 'add_ons.toml'
    toml_data   = TomlRB.load_file(toml_path)
    data_pkgs   = toml_data['packages']
    types       = %w(debian_apt ruby_gems)

    for type in types do
      for line in data_pkgs[type].split("\n") do
        next if line =~ /^#/        # Skip comment lines.
        next if line =~ /^\s*$/     # Skip empty lines.
        puts fmt_1 % [type, line]

        title, name, notes = get_fields(line)
        unless name && notes
          puts 'Parse error detected; exiting.'
          exit
        end
        time_start  = Time.now()

        case type
        when 'debian_apt'
          system('get_apt', log_dir, name)
          status      = $?
        when 'ruby_gems'
          system('get_gem', log_dir, name)
          status      = $?
        end

        date_info   = `date`.strip
        duration    = Time.now() - time_start

        log_path    = "#{ log_dir }/#{ name }"
        log_size    = File.readlines(log_path).size()
        puts fmt_2 % [date_info, duration, log_size]

        info_pkgs[name] = {
          duration:   duration,
          log_size:   log_size,
          notes:      notes,
          status:     status,
          title:      title,
          type:       type
        }
      end
    end
    report(info_pkgs)
  end

  def get_fields(line)
    line.split(',').map {|field| field.strip }
  end

  def report(info_pkgs)
    dur_secs  = 0
    format    = '  %-20s  %-20s  %-4s  %7.1f  %4d'
    issues    = []
    names     = info_pkgs.keys.sort

    for name in names do
      info      = info_pkgs[name]
      dur_secs += info[:duration]

      if info[:status] != 0
        issue = format % [name, info[:type],
          info[:status], info[:duration], info[:log_size] ]
        issues.push(issue)
      end
    end

    if issues.size == 0
      puts 'Loading issues: none'
    else
      puts 'Loading issues:'
      issues.each {|issue| puts issue }
    end

    puts
    apt_list  = `apt list --installed 2>&-`
    apt_size  = apt_list.split("\n").size()
    dur_mins  = dur_secs / 60.0
    puts 'Named packages: %6d' % [names.size]
    puts 'Total packages: %6d' % [apt_size]
    puts 'Duration: %.1f seconds (%.1f minutes)' % [dur_secs, dur_mins]
  end

  main()