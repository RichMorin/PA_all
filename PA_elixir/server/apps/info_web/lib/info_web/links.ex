# info_web/links.ex

defmodule InfoWeb.Links do
#
# Public functions
#
#   do_links/2
#     Process link tuples from the parsed page (aka HTML tree).
#
# Private functions
#
#   check_link_elts/2
#     Report structural problems with link elements.
#   get_link_tuples/2
#     Get a list of tuples describing link URLs.

  @moduledoc """
  This module handles checking (etc) of links for `InfoWeb.Internal`.
  """

  use InfoWeb.Types

  # Public functions

  @doc """
  Process link tuples from the parsed page (aka HTML tree).
  """

  @spec do_links([tuple], String.t) :: [tuple]

  def do_links(html_tree, page_url) do

    html_tree
    |> Floki.find("a[href]")
    |> check_link_elts(page_url)
    |> get_link_tuples(page_url)
  end

  # Private functions

  @spec check_link_elts([tuple], String.t) :: [tuple]

  defp check_link_elts(link_elts, page_url) do
  #
  # Report structural problems with link elements.
  #
  # At present, we only check for missing title attributes.
  # We also summarize fragment links ("#..."), for brevity.
  #
  # The `link_elts` List should have the following structure:
  #
  #   [
  #     { "a",
  #       [ { "href",  "/" },
  #         { "title", "Go to: Home [local]" } ],
  #       [ "Home" ]
  #     }, ...
  #   ]

    filter_fn = fn message  -> message end

    map_fn    = fn link_elt ->
      href    = link_elt
      |> Floki.attribute("href")
      |> Enum.at(0)
      |> String.replace(~r{^#.*$}, "#...")
      
      title   = Floki.attribute(link_elt, "title")

      if Enum.empty?(title) do
        "Link has no title, href: '#{ href }'"
      else
        nil
      end
    end

    messages  = link_elts
    |> Enum.map(map_fn)
    |> Enum.filter(filter_fn)
    |> Enum.uniq()

    if !Enum.empty?(messages) do
      msg_str   = Enum.join(messages, "\n  ")

      IO.puts "\n>>> #{ page_url }"
      IO.puts "  #{ msg_str }"
    end

    link_elts
  end

  @spec get_link_tuples([tuple], String.t) :: [tuple]

  defp get_link_tuples(link_elts, page_url) do
  #
  # Get a list of tuples describing link URLs.

    reduce_fn   = fn link_url, acc ->
      status  = if link_url =~ ~r{^http} do :ext else :seen end
      tuple   = { status, "", page_url, link_url }

      [ tuple | acc ]
    end

    link_elts
    |> Floki.attribute("href")
    |> Enum.reduce([], reduce_fn)
  end

end