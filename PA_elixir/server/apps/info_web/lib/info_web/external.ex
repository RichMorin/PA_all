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

  import Common, only: [ ii: 2 ]

  alias InfoWeb.Types, as: IWT

  # Public functions

  @doc """
  Get a list of status tuples for external URLs.  The `forced` map tells us
  which URLs should be forced to verify as OK.
  """

  @spec get_ext_list([IWT.link_3], IWT.ok_map) :: [IWT.link_4]

  def get_ext_list(external, forced) do
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
      recv_timeout:     30_000,
      timeout:          30_000
    ]

    chk_url_fn  = fn {_note, from_page, link_url} ->
    #
    # Check the URL and return the results as a tuple.

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

    external |> Enum.map(chk_url_fn)
  end

end
