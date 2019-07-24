# info_web/checker.ex

defmodule InfoWeb.Checker do
#
# Public functions
#
#   check_pages/0
#     Crawl the default web site, checking any pages found on it.
#   check_pages/1
#     Crawl the specified web site, checking any pages found on it.
#
# Private functions
#
#   get_forced/0
#     Get a list of "forced" external URLs.
#   mapper/1
#     Construct a map of links, binned by their status.

  @moduledoc """
  This module is a home-grown, special-purpose web crawler and sanity checker
  for the Pete's Alley web site.  It uses HTTPoison to retrieve web pages
  and Floki to extract information from their HTML.
  
  The scanning has several goals, including:
  
  - Detecting broken links, so that we can (manually) eliminate them.
    Although there may be multiple instances of a broken link, we
    only need to report a single instance, along with its `from_page`.

  - Detecting missing `title` attributes.
  
  - Detecting jumps in heading levels.

  # Data Structures
  
  The working data structure is a list of tuples, each of which contains
  information on an HTML link:

      [ { status, note, from_path, page_url } ]

  The status may be one of the following atoms:

  - `:ext`      - external link
  - `:ext_ng`   - external link with an error
  - `:ext_ok`   - external link with no errors
  - `:int_ng`   - internal link with an error
  - `:int_ok`   - internal link with no errors
  - `:seen`     - a link we've seen

  # Data Flow

  First, we crawl the internal pages, generating a map of lists of tuples.
  The map keys are `:ext`, `:int_ng`, and `:int_ok`.   Then, we crawl the
  `:ext` entries, determining whether their URLs are valid.
  
  If an external URL is listed in either the `_config/forced.toml` file or
  the most recent `PA_links/*/*.toml` file, we accept it as valid without
  performing a web access.  This keeps us from bothering with URLs that we
  know to be valid, saving both human and machine time.
  """

  import Common, warn: false,
    only: [ csv_split: 1, ii: 2, get_http_port: 0 ]

  alias InfoWeb.{External, Internal, Server, Snapshot}
  alias InfoWeb.Types, as: IWT

  # Public functions

  @doc """
  This function checks both internal and external links on Pete's Alley.
  The returned value is a map of the form:
  
      %{
        bins:     %{
          <status>: [ { note, from_path, page_url }, ... ]
        }
        forced:   %{
          <url> => true
        }
      }
  """

  @spec check_pages() :: IWT.result_map

  def check_pages() do
  #
  # $ iex -S mix
  # iex> t = InfoWeb.check_pages;1
  # iex> t = InfoWeb.get_snap;1

    domain      = "http://localhost" #!K
    http_port   = get_http_port()
    url_base    = "#{ domain }:#{ http_port }"

    check_pages(url_base)
  end

  @spec check_pages(String.t) :: IWT.result_map

  defp check_pages(url_base) do

    base_list   = [ { :seen, "root page", "", "/" } ]
    forced      = get_forced()

    int_map     = base_list
    |> Internal.get_int_list(url_base)
    |> mapper()

    ext_map     = int_map.ext
    |> External.get_ext_list(forced)
    |> mapper()

    result  = %{
      bins:     Map.merge(ext_map, int_map),
      forced:   forced,
    }

    Snapshot.snap_save(result)
    Server.reload()

    result
#   |> ii(:result) #!T
  end

  # Private functions

  @spec get_forced() :: IWT.ok_map

  defp get_forced() do
  #
  # Return a map of "forced" external URLs.

    forced_fn   = fn {_key, val}, acc -> csv_split(val) ++ acc end
    #
    # Return a list of "forced" external URLs.

    forced      = InfoToml.get_item("_config/forced.toml").urls
    |> Enum.reduce([], forced_fn)

    reduce_fn   = fn key, acc -> Map.put(acc, key, :true) end
    #
    # Build a map with `true` entries for each key.

    snap_map    = Snapshot.snap_load()
    gi_list     = ["raw", "ext_ok"]
    ext_ok      = get_in(snap_map, gi_list)

    (forced ++ ext_ok) |> Enum.reduce(%{}, reduce_fn)
  end

  @spec mapper( [IWT.link_work] ) :: IWT.bins_map

  defp mapper(inp_list) do
  #
  # Construct a map from a list of links, binned by their status.

    entry_fn  = fn { status, note, page_url, link_url }, acc ->
    #
    # Generate and store a map entry.

      out_item    = { note, page_url, link_url }
      initial     = [ out_item ]
      update_fn   = fn current -> [ out_item | current ] end

      Map.update(acc, status, initial, update_fn)
    end

    Enum.reduce(inp_list, %{}, entry_fn)
  end

end
