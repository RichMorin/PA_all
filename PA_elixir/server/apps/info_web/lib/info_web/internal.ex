# info_web/internal.ex

defmodule InfoWeb.Internal do
#
# Public functions
#
#   get_int_list/2
#     Wrapper for get_int_list/3.
#   get_int_list/3
#     Iterate on the list until all local links are handled.
#
# Private functions
#
#   add_local/3
#     Add local URLs to the input list.
#   add_local_h/3
#     Return a list of link tuples for the URL.
#   discard/2
#     Discard "duplicate" and "time sink" URLs.

  @moduledoc """
  This module crawls the Pete's Alley web site, extracting links and binning
  them into several categories.  It uses HTTPoison to retrieve web pages
  and Floki to extract link information.
  
  ## Data Flow
  
  We start out with a single element list, containing the `status` (`:seen`),
  a note (`"root page"`), the `from_page` (nil), and the `page_url` (`"/"`)
  for the root page of the site:
  
      [ { :seen, "root page", nil, "/" } ]
  
  We expand this list in a recursive manner.  Each pass attempts to retrieve
  and parse the `:seen` (but not "known") pages.  When there are no more of
  these, we declare the process to be finished.
  
  If we can't retrieve an internal URL, we change its status to `:int_ng`.
  Otherwise, we change its status to `:int_ok` and harvest a list of URLs.
  These get a status of either `:ext` or `:seen`, depending on whether they
  begin with `"http"`.

  To reduce the workload, we trim the working list, discarding:
  
  - all but one instance of each status/URL combination
  - a variety of "time sink" internal URLs (e.g., `"/reload?"`)
  """

  import Common, only: [ssw: 2]
  import InfoWeb.Common, only: [validate_uri: 1]

  alias InfoWeb.{Headings, Links}
  alias InfoWeb.Types, as: IWT

  # Public functions

  @doc """
  Iterate on the list until all local links are handled.
  """

  @spec get_int_list(tl, String.t) :: tl
    when tl: [IWT.link_4]

  def get_int_list(inp_list, url_base) do #D
  #
  # Wrapper for get_int_list/3.

    get_int_list(inp_list, url_base, %{})
  end

  # Private functions

  @spec add_local(String.t, tl, map) :: tl
    when tl: [IWT.link_4]

  defp add_local(url_base, inp_urls, known) do
  #
  # Add local URLs to the input list.

    tuple_fn  = fn tuple = { status, _note, from_url, page_url } ->
    #
    # Return the input tuple or generate a list of tuples.

      cond do
        known[page_url]       -> tuple

        status != :seen       -> tuple

        ssw(page_url, "http") -> tuple

        true -> add_local_h(from_url, page_url, url_base)
      end
    end

    inp_urls
    |> Enum.map(tuple_fn)
    |> List.flatten()
    |> Enum.sort()
    |> discard(url_base)
  end

  @spec add_local_h(st, st, st) :: [IWT.link_4]
    when st: String.t

  defp add_local_h(from_url, page_url, url_base) do
  #
  # Return a list of link tuples for the URL.

    full_url  = url_base <> page_url

    uri_ok    = if ssw(page_url, "/") do
      {status, _uri} = validate_uri(full_url)
      status == :ok
    else
      false
    end

    if uri_ok do
      response  = HTTPoison.get!(full_url)

      if response.status_code == 200 do

        html_tree   = response.body |> Floki.parse()

        links       = html_tree
        |> Headings.do_headings(page_url)
        |> Links.do_links(page_url)

        [ { :int_ok, "", from_url, page_url } | links ]
      else
        [ { :int_ng, "", from_url, page_url } ]
      end
    else
      [ { :int_ng, "", from_url, page_url } ]
    end
  end

  @spec discard(tl, String.t) :: tl
    when tl: [IWT.link_4]

  defp discard(tuples, url_base) do
  #
  # Discard duplicate and problematic (e.g., recursive, time sink) URLs.

    reject_fn = fn {_status, _note, _page_url, link_url } ->
    #
    # Return true for problematic URLs.

      test_url  = String.replace_prefix(link_url, url_base, "")

      usw_fn    = fn url -> ssw(test_url, url) end
      #
      # Return true if the URL starts with any of several strings.

      usw_fn.("/item?key=Areas/Catalog/")   ||  # D - comment to speed up
      usw_fn.("#")                          ||  # section of same page
      usw_fn.("/dash/links")                ||  # recursive, in a way
      usw_fn.("/item/edit?")                ||  # time sink
      usw_fn.("/mail/feed?")                ||  # time sink
      usw_fn.("/reload?")                   ||  # time sink
      usw_fn.("/search/")                   ||  # time sink
      usw_fn.("/source?")                   ||  # time sink
      usw_fn.("/source/down?")
    end

    uniq_fn   = fn { status, _note, _page_url, link_url } ->
    #
    # Return a text string that can be used to produce a unique list.

      "#{ status } #{ link_url }"
    end

    tuples
    |> Enum.uniq_by(uniq_fn)
    |> Enum.reject(reject_fn)
  end

  @spec get_int_list(tl, String.t, IWT.ok_map) :: tl
    when tl: [IWT.link_4]

  defp get_int_list(inp_list, url_base, known) do
  #
  # Iterate on the list until all local links are handled.

    out_list    = add_local(url_base, inp_list, known)

    seen_fn     = fn {status, _, _, _} -> status == :seen end
    #
    # Return true if this URL has already been seen.

    seen_list   = out_list |> Enum.filter(seen_fn)

    reduce_fn   = fn { _, _, _, url }, acc -> Map.put(acc, url, true) end
    #
    # Generate a map with URLs as keys and true for all values.

    known       = out_list
    |> Enum.reject(seen_fn)
    |> Enum.reduce(known, reduce_fn)

    known_fn    = fn { _, _, _, url } -> known[url] end
    #
    # Return true if this is a known URL.

    todo_list   = seen_list |> Enum.reject(known_fn)

    if Enum.empty?(todo_list) do
      out_list
    else
      get_int_list(out_list, url_base, known) #R
    end
    |> Enum.reject(seen_fn)
  end

end
