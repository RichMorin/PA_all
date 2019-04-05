defmodule InfoWeb.Checker do
#
# Public functions
#
#   check_links/1
#     Crawl the specified web site, checking any links found on it.
#
# Private functions
#
#   get_forced/0
#     Get a list of "forced" external URLs.
#   mapper/1
#     Construct a Map of links, binned by their status.
#   snap_load/0
#     Load a snapshot of the `result` Map.
#   snap_save/1
#     Save a snapshot of the `result` Map.

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
  alias InfoWeb.{External, Internal}

  @doc """
  This function checks both internal and external links on Pete's Alley.
  The returned value is a Map of the form:
  
    %{
      bins: %{
        <status>: [ { note, from_path, page_url } ]
      }
    }
  """

# @spec - WIP

  def check_links(url_base \\ nil) do
  #
  # iex> t = InfoWeb.check_links("http://localhost:4000");1

    domain      = "http://localhost" #K
    http_port   = System.get_env("PORT") || "4000"
    url_base    = url_base || "#{ domain }:#{ http_port }"

    base_list   = [ { :seen, "root page", nil, "/" } ]
    forced      = get_forced()

    int_map     = base_list
    |> Internal.get_int_list(url_base)
    |> mapper()

    ext_map     = int_map.ext
    |> External.get_ext_list(forced)
    |> mapper()

    if true do #TG
      IO.puts ""
      ii(int_map[:ext_ng], :ext_ng)
      IO.puts ""
      ii(int_map[:int_ng], :int_ng)
      IO.puts ""
    end

    bins    = Map.merge(int_map, ext_map)
    result  = %{ bins: bins }
    snap_save(result)

    result
  end

  # Private functions

# @spec - WIP

  defp get_forced() do
  #
  # Get a Map of "forced" external URLs.

    reduce_fn1  = fn {_key, val}, acc -> str_list(val) ++ acc end
    forced      = InfoToml.get_item("_config/forced.toml").urls
    |> Enum.reduce([], reduce_fn1)

    reduce_fn2  = fn key, acc -> Map.put(acc, key, :true) end
    snapped     = snap_load()

    (forced ++ snapped) |> Enum.reduce(%{}, reduce_fn2)
  end

# @spec - WIP

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

# @spec - WIP

  def snap_load() do
  #
  # Load the most recent snapshot of the `result` Map.
  
    link_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_links" #K
    glob_patt   = "#{ link_base }/*/*.toml"

    file_data   =  glob_patt
    |> Path.wildcard()
    |> Enum.reverse()
    |> hd()
    |> InfoToml.Parser.parse(:atoms)

    file_data.ext_ok |> str_list()
  end

# @spec - WIP

  defp snap_save(result) do
  #
  # Save a snapshot of the `result` Map.
  
    link_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_links" #K
    ok_urls     = result.bins.ext_ok

    toml_list   = for ok_url <- ok_urls do
      {_status, _from_page, ext_url} = ok_url

      "#{ ext_url },"
    end
    |> Enum.sort()
    |> Enum.join("\n")

    toml_text   = """
    # PA_links

      ext_ok  = '''
    #{ toml_list }
      '''
    """

    InfoToml.Emitter.emit_toml(link_base, toml_text)
  end
end
