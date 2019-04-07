defmodule InfoWeb.Internal do
#
# Public functions
#
#   get_int_list/3
#     Iterate on the list until all local links are handled.
#
# Private functions
#
#   add_local/3
#     Add local URLs to the input list.

  @moduledoc """
  This module crawls the Pete's Alley web site, extracting links and binning
  them into several categories.  It uses HTTPoison to retrieve web pages
  and Floki to extract link information.
  
  ## Data Flow
  
  We start out with a single element list, containing the `status` (:seen),
  a note ("root page"), the `from_page` (nil), and the `page_url` (/) for
  the root page of the site:
  
      [ { :seen, "root page", nil, "/" } ]
  
  We expand this list in a recursive manner.  Each pass attempts to retrieve
  and parse the `:seen` (but not "known") pages.  When there are no more of
  these, we declare the process to be finished.
  
  If we can't retrieve an internal URL, we change its status to `:int_ng`.
  Otherwise, we change its status to `:int_ok` and harvest a list of URLs.
  These get a status of either `:ext` or `:seen`, depending on whether they
  begin with `http`.

  To reduce the workload, we trim the working list, discarding:
  
  - all but one instance of each status/URL combination
  - a variety of "rathole" internal URLs (e.g., "/reload?")
  """

  use Common,   :common
  use InfoWeb,  :common
  use InfoWeb.Types

  @spec get_int_list([{}], String.t, map) :: list

  def get_int_list(inp_list, url_base, known \\ %{}) do
  #
  # Iterate on the list until all local links are handled.

    out_list    = add_local(url_base, inp_list, known)

    filter_fn1  = fn {status, _, _, _} -> status == :seen end
    seen_list   = out_list |> Enum.filter(filter_fn1)

    filter_fn2  = fn {status, _, _, _} -> status != :seen end
    reduce_fn   = fn { _, _, _, url }, acc -> Map.put(acc, url, true) end

    known       = out_list
    |> Enum.filter(filter_fn2)
    |> Enum.reduce(known, reduce_fn)

    reject_fn1  = fn { _, _, _, url }     -> known[url] end
    reject_fn2  = fn { status, _, _, _ }  -> status == :seen end

    todo_list   = seen_list |> Enum.reject(reject_fn1)

    if Enum.empty?(todo_list) do
      out_list
    else
      get_int_list(out_list, url_base, known) #R
    end
    |> Enum.reject(reject_fn2)
  end

  # Private functions

  @spec add_local(String.t, list, map) :: list

  def add_local(url_base, inp_urls, known) do
  #
  # Add local URLs to the input list.

    map_fn    = fn tuple = { status, _note, from_url, page_url } ->
      cond do
        known[page_url]                       -> tuple

        status != :seen                       -> tuple

        String.starts_with?(page_url, "http") -> tuple

        true ->
          full_url  = url_base <> page_url

          uri_ok    = if String.starts_with?(page_url, "/") do
            {status, _uri} = validate_uri(full_url)
            status == :ok
          else
            false
          end
 
          if uri_ok do
            response  = HTTPoison.get!(full_url)

            if response.status_code == 200 do
              reduce_fn   = fn link_url, acc ->
                status  = if link_url =~ ~r{^http} do :ext else :seen end

                tuple   = { status, "", page_url, link_url }
                [ tuple | acc ]
              end

              links   = response.body
              |> Floki.parse()
              |> Floki.attribute("a", "href")
              |> Enum.reduce([], reduce_fn)

              [ { :int_ok, "", from_url, page_url } | links ]
            else
              { :int_ng, "", from_url, page_url }
            end
          else
            { :int_ng, "", from_url, page_url }
          end
      end
    end

    reject_fn   = fn { _status, _note, _page_url, link_url } ->
      test_url  = String.replace_prefix(link_url, url_base, "")

      String.starts_with?(test_url, "#")              ||
      String.starts_with?(test_url, "/item/edit?")    ||
      String.starts_with?(test_url, "/mail/feed?")    ||
      String.starts_with?(test_url, "/reload?")       ||
      String.starts_with?(test_url, "/search/")       ||
      String.starts_with?(test_url, "/source?")       ||
      String.starts_with?(test_url, "/source/down?")
    end

    uniq_fn   = fn { status, _note, _page_url, link_url } ->
      "#{ status } #{ link_url }"
    end

    inp_urls
    |> Enum.map(map_fn)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.uniq_by(uniq_fn)
    |> Enum.reject(reject_fn)
  end

end
