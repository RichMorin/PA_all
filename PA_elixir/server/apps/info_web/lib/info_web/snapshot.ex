# info_web/snapshot.ex

defmodule InfoWeb.Snapshot do
#
# Public functions
#
#   counts_ext/1
#     Count links to external sites; format as sorted TOML.
#   counts_int/1
#     Count links to internal routes; format as sorted TOML.
#   raw_ext_urls/1
#     Format `ext_ok` data (OK external URLs).
#   snap_load/0
#     Load a snapshot of the `result` map.
#   snap_save/1
#     Save a (reworked) snapshot of the `result` map, in TOML format.

  @moduledoc """
  This module handles reading and writing of TOML snapshot files.
  """

  import Common, warn: false, only: [ ii: 2, sort_by_elem: 2 ]

  # Public functions

  @doc """
  Count links to external sites; format as sorted TOML.
  """

  @spec counts_ext(map) :: String.t

  def counts_ext(result) do

    site_fn   = fn {_status, _from_page, ext_url} ->
    #
    # Extract the name of the web site (e.g., foo.com) from the URL.

      pattern   = ~r{ ^ .* // ( [^/]+ ) .* $ }x
      String.replace(ext_url, pattern, "\\1")
    end

    counts_fn   = fn site, acc -> Map.update(acc, site, 1, &(&1+1)) end
    #
    # Build a map of web site usage counts.

    tuples = result.bins.ext_ok
#   |> ii(:ext_ok) #T
    |> Enum.map(site_fn)
    |> Enum.reduce(%{}, counts_fn)

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
  Count links to internal routes; format as sorted TOML.
  """

  @spec counts_int(map) :: String.t

  def counts_int(result) do

    abridge_fn    = fn {_status, _from_page, int_url} ->
    #
    # Remove any query from the URL.

      String.replace(int_url, ~r{\?.*}, "")
    end

    counts_fn   = fn url, acc -> Map.update(acc, url, 1, &(&1+1)) end
    #
    # Build a map of internal page usage counts.

    tuples = result.bins.int_ok
#   |> ii(:int_ok) #T
    |> Enum.map(abridge_fn)
    |> Enum.reduce(%{}, counts_fn)

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

    fmt_fn  = fn {status, from_page, url} ->
    #
    # Format the tuple as TOML.

      """
          [ '#{ url  }',
            '#{ from_page  }',
            '#{ status  }' ],
      """
    end

    bin_list  = result.bins[key] || []

    out_list  = bin_list
    |> sort_by_elem(2)
    |> Enum.map(fmt_fn)
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

    url_fn   = fn {_status, _from_page, url} -> url end
    #
    # Extract the URL component from the tuple.

    fmt_fn    = fn url -> "    \"#{ url }\"," end #K - urlencode?
    #
    # Format the URL as TOML.

    out_list  = result.bins.ext_ok    # [ {<status>, <from_page>, <url>}, ... ]
    |> Enum.map(url_fn)               # [ <url>, ... ]
    |> Enum.sort()                    # same, but sorted
    |> Enum.map(fmt_fn)               # [ "    '<url>',", ... ]
    |> Enum.join("\n")                # "    '<url>',\n, ... "

    """
      ext_ok = [
    #{ out_list }
      ]
    """
  end

  @doc """
  Load a map containing the most recent snapshot of the `result` map.
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
      file_path = file_paths  |> List.last()
      file_data = file_path   |> InfoToml.Parser.parse(:string)

      if Enum.empty?(file_data) do
        message = "result snapshot file #{ file_path } not loaded"
        IO.puts ">>> #{ message }\n"
        %{}
      else
        file_data
      end
    end
  end

  @doc """
  Save a (reworked) snapshot of the `result` map, in TOML format.
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

    InfoToml.Emitter.emit_toml(link_base, ".links", toml_text)
  end

end
