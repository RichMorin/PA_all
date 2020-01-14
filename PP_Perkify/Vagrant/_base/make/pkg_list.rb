#!/usr/bin/env ruby
#
# pkg_list.rb - extract, sort, and format a list of packages
#
# The packages section of add_ons.toml is formatted as TOML and divided into
# topical sections (eg, debian_apt_a11y).  So, it cannot be used directly in
# con_ove|Perkify_Pkg_List.  This script remedies that situation, producing
# Markdown code that can be included by the item's main.toml file, e.g.:
#
#   {% include_relative ./pkg_tbl.md %}
#
# Written by Rich Morin, CFCL, 2019.

  require 'fileutils'
  require 'toml-rb'

  def main()
    toml_path   = 'add_ons.toml'
    toml_data   = TomlRB.load_file(toml_path)
    packages    = toml_data['packages']
    info_pkgs   = {}
    pkg_cnt     = 0
    tag_patt    = /^ .+? ([^_]+) $/x
    types       = packages.keys

    # Collect package data from file.

    for type in types do
      next unless type =~ /^debian_apt_/

      lines     = packages[type].split("\n")
      tag       = type.sub(tag_patt, '\\1')

      for line in lines do
        next if line =~ /^#/        # Skip comment lines.
        next if line =~ /^\s*$/     # Skip empty lines.
        line.sub!(/^!/, ' ')
        pkg_cnt  += 1

        title, name, notes = get_fields(line)

        unless name && notes
          puts 'Parse error detected; exiting.'
          puts "line: '#{ line }'"
          exit
        end

        info_pkgs[title] = {
          name:   name,
          notes:  notes,
          tag:    tag
        }
      end
    end

    # Format and output package data.

    format  = '| %-30s | %-30s | %-30s | %-30s |'
    titles  = info_pkgs.keys.sort

    categories  = {
      'a11y'    => 'accessibility',     # braille, screen readers, speech, ... 
      'admin'   => 'administration',    # network and system administration
      'comm'    => 'communication',     # chat, email, messages, VoIP, ...
      'desk'    => 'desktops, tools',   # desktop environments, apps, ...
      'docs'    => 'documentation',     # document generation tools and suites
      'games'   => 'games, etc.',       # game engines and programs
      'image'   => 'images, etc.',      # image generators and processors 
      'math'    => 'mathematics',       # calculators, spreadsheets, ...
      'media'   => 'audio, video',      # music players, sound editors, ...
      'ocr'     => 'OCR support',       # optical character recognition tools
      'prog'    => 'programming',       # commands, languages, libraries, ...
      'term'    => 'terminal support',  # emulators, multiplexers, ...
      'web'     => 'world wide web',    # HTTP servers, web browsers, ...
      'zoo'     => 'everything else'    # ... 
    }

    out_list    = [ "<!-- .../Perkify_Pkg_List/pkg_tbl.md -->\n" ]
    out_list   << format % [ 'Category', 'Title', 'APT name', 'Description' ]
    out_list   << format % [ '--------', '-----', '--------', '-----------' ]

    for title in titles do
      info_pkg    = info_pkgs[title]
      tag         = info_pkg[:tag]
      notes       = info_pkg[:notes]
      category    = categories[tag]
      link        = "A$#{ info_pkg[:name] }$"
      out_list   << format % [ category, title, link, notes ]
    end

    #!K - This assumes that the script will be run from a specific directory.
    #
    out_path  = '../../../../PA_toml/Areas/Content/Overviews/' +
                'Perkify_/Perkify_Pkg_List/pkg_tbl.md'
    out_str   = out_list.join("\n")

#   puts out_str #!T
    File.open(out_path, 'w') { |f| f.puts out_str }
    puts "\npackage count: #{ pkg_cnt }"
  end

  def get_fields(line)
    line.split(',').map {|field| field.strip }
  end

  main()
