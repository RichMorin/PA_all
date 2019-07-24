# controllers/_make.ex

defmodule PhxHttpWeb.Cont.Make do
#
# Public functions
#
#   packages/0
#     Collect information on software packages.
#
# Private functions

  @moduledoc """
  This module contains helper functions for the Make Dashboard.
  """

  import Common, only: [ csv_split: 1 ]

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  This function collects information on software packages.
  """

  @spec packages() :: PHT.pkg_map

  def packages() do

    main_fn     = fn {key, _title, _precis} ->
    #
    # Return true if this is the main file for an item.

      String.ends_with?(key, "/main.toml")
    end

    build_fn  = fn map ->
    #
    # Return true if we can build package for any OS.

      make    = map.make

      make.main || make.arch || make.debian || make.other
    end

    items_fn   = fn inp_map, acc ->
    #
    # Build a map of information on items.

      name    = inp_map.make.name
      Map.put(acc, name, inp_map)
    end

    "Areas/Catalog/Software/"
    |> InfoToml.get_item_tuples()   # [ {key, title, precis}, ... ]
    |> Enum.filter(main_fn)         # keep items with ".../main.toml" keys
    |> Enum.map(&package/1)         # [ { key, title, precis, map }, ... ]
    |> Enum.filter(build_fn)        # keep items we can build
    |> Enum.reduce(%{}, items_fn)   # construct a map of item info
  end

  # Private functions

  @spec package({st, st, st}) :: PHT.pkg_info
    when st: String.t

  defp package {main_key, title, precis} do
  #
  # Collect information on a single package.

    main_data   = main_key |> InfoToml.get_item()

    make_data   = main_key
    |> String.replace_suffix("/main.toml", "/make.toml")
    |> InfoToml.get_item()

    make_fn     = fn os_key ->
    #
    # Return true if we can build package for this operating system.

      gi_path     = [ :os, os_key, :package ]
      get_in(make_data, gi_path) |> is_binary()
    end

    main_fn     = fn ->
    #
    # Return true if we want to build this package.

      gi_path   = [ :meta, :actions ]

      get_in(main_data, gi_path)
      |> csv_split()
      |> Enum.member?("build")
    end

    pattern   = ~r{ \s+ \( .* $ }x
    name      = main_data.meta.title
    |> String.replace(pattern, "")

    %{
      main:  %{  #!D
        key:      main_key,
        precis:   precis,
        title:    title,
      },

      make:  %{  #!D
        arch:     make_fn.(:arch),
        debian:   make_fn.(:debian),
        main:     main_fn.(),
        name:     name,
        other:    make_fn.(:zoo),
      }
    }
  end

end
