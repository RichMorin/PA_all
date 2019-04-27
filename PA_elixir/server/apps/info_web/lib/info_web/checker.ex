defmodule InfoWeb.Checker do
#
# Public functions
#
#   check_links/0
#     Crawl the default web site, checking any links found on it.
#   check_links/1
#     Crawl the specified web site, checking any links found on it.
#
# Private functions
#
#   get_forced/0
#     Get a list of "forced" external URLs.
#   mapper/1
#     Construct a Map of links, binned by their status.

  @moduledoc """
  This module is a home-grown, special-purpose web crawler and link checker
  for the Pete's Alley web site.  It uses HTTPoison to retrieve web pages
  and Floki to extract link information.
  
  The goal is to detect broken links, so that we can (manually) eliminate
  them.  So, although there may be multiple instances of a broken link, we
  only need to report a single instance, along with its `from_page`.

  # Data Structures
  
  The working data structure is a List of Tuples, each of which contains
  information on an HTML link:

    [ { status, note, from_path, page_url } ]

  The status may be one of the following Atoms:

  - :ext      - external link
  - :ext_ng   - external link with an error
  - :ext_ok   - external link with no errors
  - :int_ng   - internal link with an error
  - :int_ok   - internal link with no errors
  - :seen     - a link we've seen

  # Data Flow

  First, we crawl the internal pages, generating a Map of Lists of Tuples.
  The Map keys are `:ext`, `:int_ng`, and `:int_ok`.   Then, we crawl the
  `:ext` entries, determining whether their URLs are valid.
  
  If an external URL is listed in either the `_config/forced.toml` file or
  the most recent `PA_links/*/*.toml` file, we accept it as valid without
  performing a web access.  This keeps us from bothering with URLs that we
  know to be valid, saving both human and machine time.
  """

  use Common,   :common
  use InfoWeb,  :common
  use InfoWeb.Types

  alias InfoWeb.{External, Internal, Server, Snapshot}

  @doc """
  This function checks both internal and external links on Pete's Alley.
  The returned value is a Map of the form:
  
    %{
      bins:     %{
        <status>: [ { note, from_path, page_url }, ... ]
      }
      forced:   [ <url>, ... ]
    }
  """

  @spec check_links() :: map

  def check_links() do
  #
  # $ iex -S mix
  # iex> t = InfoWeb.check_links;1
  # iex> t = InfoWeb.get_snap;1

    domain      = "http://localhost" #K
    http_port   = get_http_port()
    url_base    = "#{ domain }:#{ http_port }"

    check_links(url_base)
  end

  @spec check_links(String.t) :: map

  defp check_links(url_base) do

    base_list   = [ { :seen, "root page", nil, "/" } ]
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
#   |> ii(:result) #T
  end

  # Private functions

  @spec get_forced() :: map

  defp get_forced() do
  #
  # Get a Map of "forced" external URLs.

    reduce_fn1  = fn {_key, val}, acc -> str_list(val) ++ acc end
    forced      = InfoToml.get_item("_config/forced.toml").urls
    |> Enum.reduce([], reduce_fn1)

    reduce_fn2  = fn key, acc -> Map.put(acc, key, :true) end
    snap_map    = Snapshot.snap_load()
    gi_list     = ["raw", "ext_ok"]
    ext_ok      = get_in(snap_map, gi_list)

    (forced ++ ext_ok) |> Enum.reduce(%{}, reduce_fn2)
  end

  @spec mapper([tuple]) :: map

  defp mapper(inp_list) do
  #
  # Construct a Map from a List of links, binned by their status.

    reduce_fn = fn { status, note, page_url, link_url }, acc ->
      out_item    = { note, page_url, link_url }
      initial     = [ out_item ]
      update_fn   = fn current -> [ out_item | current ] end

      Map.update(acc, status, initial, update_fn)
    end

    Enum.reduce(inp_list, %{}, reduce_fn)
  end

end
