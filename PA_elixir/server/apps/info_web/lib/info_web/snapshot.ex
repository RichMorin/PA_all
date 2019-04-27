defmodule InfoWeb.Snapshot do
#
# Public functions
#
#   counts_ext/1
#     Count links to external sites.
#   counts_int/1
#     Count links to external routes.
#   raw_ext_urls/1
#     Format `ext_ok` data (OK external URLs).
#   snap_load/0
#     Load a snapshot of the `result` Map.
#   snap_save/1
#     Save a (reworked) snapshot of the `result` Map, in TOML format.

  @moduledoc """
  This module handles reading and writing of TOML snapshot files.
  """

  use Common,   :common
  use InfoWeb,  :common
  use InfoWeb.Types

  @doc """
  Count links to external sites, format as TOML.
  """

  @spec counts_ext(map) :: String.t

  def counts_ext(result) do
    pattern   = ~r{ ^ .* // ( [^/]+ ) .* $ }x

    map_fn    = fn {_status, _from_page, ext_url} ->
      String.replace(ext_url, pattern, "\\1")
    end

    reduce_fn   = fn key, acc -> Map.update(acc, key, 1, &(&1+1)) end

    tuples = result.bins.ext_ok
    |> ii(:ext_ok)
    |> Enum.map(map_fn)
    |> Enum.reduce(%{}, reduce_fn)

    out_lines  = for {site, count} <- tuples do
      "  '#{ site }' = #{ count }"
    end
    |> Enum.sort()
    |> Enum.join("\n")

    """
    [ counts.ext ]

    #{ out_lines }
    """
  end

  @doc """
  Count links to internal routes, format as TOML.
  """

  @spec counts_int(map) :: String.t

  def counts_int(result) do
    map_fn      = fn {_status, _from_page, int_url} ->
      String.replace(int_url, ~r{\?.*}, "")
    end

    reduce_fn   = fn key, acc -> Map.update(acc, key, 1, &(&1+1)) end

    tuples = result.bins.int_ok
    |> ii(:int_ok)
    |> Enum.map(map_fn)
    |> Enum.reduce(%{}, reduce_fn)

    out_lines  = for {route, count} <- tuples do
      "  '#{ route }' = #{ count }"
    end
    |> Enum.sort()
    |> Enum.join("\n")

    """
    [ counts.int ]

    #{ out_lines }
    """
  end

  @doc """
  Format bins of error info.
  """

  @spec fmt_bins(map, atom) :: String.t

  def fmt_bins(result, key) do  

    map_fn  = fn {status, from_page, url} ->
      """
          [ '#{ url  }',
            '#{ from_page  }',
            '#{ status  }' ],
      """
    end

    sort_fn = fn {_status, _from_page, url} -> url end

    bin_list  = result.bins[key] || []

    out_list  = bin_list
    |> Enum.sort_by(sort_fn)
    |> Enum.map(map_fn)
    |> Enum.join("\n")

    """
      #{ key } = [
    #{ out_list }
      ]
    """
  end

  @doc """
  Format raw `ext_ok` data (OK external URLs).
  """

  @spec raw_ext_urls(map) :: String.t

  def raw_ext_urls(result) do  

    map_fn1   = fn {_status, _from_page, url} -> url end
    map_fn2   = fn url -> "    \"#{ url }\"," end   #K - urlencode?

    out_list  = result.bins.ext_ok    # [ {<status>, <from_page>, <url>}, ... ]
    |> Enum.map(map_fn1)              # [ <url>, ... ]
    |> Enum.sort()                    # same, but sorted
    |> Enum.map(map_fn2)              # [ "    '<url>',", ... ]
    |> Enum.join("\n")                # "    '<url>',\n, ... "

    """
      ext_ok = [
    #{ out_list }
      ]
    """
  end

  @doc """
  Load a Map containing the most recent snapshot of the `result` Map.
  """

  @spec snap_load() :: map

  def snap_load() do
    link_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_links" #K
    glob_patt   = "#{ link_base }/*/*.toml"
    file_paths  =  glob_patt |> Path.wildcard()

    if Enum.empty?(file_paths) do
      message = "No result snapshot file found"
      IO.puts ">>> #{ message }\n"
      %{}

    else
      file_path = Enum.reverse(file_paths) |> hd()
      file_data = file_path |> InfoToml.Parser.parse(:string)

      if !Enum.empty?(file_data) do
        file_data
      else
        message = "result snapshot file #{ file_path } not loaded"
        IO.puts ">>> #{ message }\n"
        %{}
      end
    end
  end

  @doc """
  Save a (reworked) snapshot of the `result` Map, in TOML format.
  """

  @spec snap_save(map) :: String.t

  def snap_save(result) do
    link_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_links" #K

    toml_text   = """
    # PA_links

    [ bins ]

    #{ fmt_bins(result, :ext_ng) }
    #{ fmt_bins(result, :int_ng) }

    [ counts ]

    #{ counts_ext(result) }
    #{ counts_int(result) }

    [ raw ]

    #{ raw_ext_urls(result) }
    """

    InfoToml.Emitter.emit_toml(link_base, toml_text)
  end

end
