# info_web/external.ex

defmodule InfoWeb.External do
#
# Public functions
#
#   get_ext_list/2
#     Get a list of status tuples for external links.

  @moduledoc """
  This module handles evaluation of external links, dealing with vagaries
  such as missing pages, redirects, etc.
  """

  use InfoWeb.Types

  import Common, only: [ii: 2]

  # Public functions

  @spec get_ext_list([tuple], map) :: [tuple]

  def get_ext_list(external, forced) do
  #
  # Get a List of status Tuples for external URLs.  The `forced` Map tells us
  # which URLs should be forced to verify as OK.
  #
  # See https://hexdocs.pm/httpoison/HTTPoison.Request.html for details.

    # We tried the following User-Agent string in an effort to get LinkedIn
    # to accept our requests.  No luck so far...

    agent_str = "Mozilla/5.0 (Windows; U; Windows NT 5.1; de; rv:1.9.2.3) " <>
                "Gecko/20100401 Firefox/3.6.3"

    headers   = [ {"User-Agent", agent_str} ]

    options   = [
      follow_redirect:  true,
      max_redirect:     10,
      recv_timeout:     30000,
      timeout:          30000
    ]

    map_fn    = fn {_note, from_page, link_url} ->
      if forced[link_url] do
        {:ext_ok, "forced", from_page, link_url}
      else
        ii(link_url, :link_url) #T

        {call_status, response}  = HTTPoison.get(link_url, headers, options)

        if call_status == :ok do
          code    = response.status_code
          note    = "code: #{ code }"

          if code < 400 do
            {:ext_ok, note, from_page, link_url}
          else
            {:ext_ng, note, from_page, link_url}
          end

        else
          note      = "call status: #{ call_status }"
          {:ext_ng, note, from_page, link_url}
        end
      end
    end

    external |> Enum.map(map_fn)
  end

end
