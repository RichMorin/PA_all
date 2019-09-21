# phx_http_web/views/_address.ex

defmodule PhxHttpWeb.View.Address do
#
# Public functions
#
#   fmt_address/2
#     Format an address for display.
#
# Private Functions
#
#   fa1/2
#     Helper function for fmt_address/2:  add heading, generalize type
#   fa2/3
#     Helper function for fa1/2:          define a formatting function
#   fa3/3
#     Helper function for fa2/3:          format heading and list

  @moduledoc """
  This module supports rendering of the `item` templates.
  """

  use Phoenix.HTML
# use PhxHttpWeb, :view

  import Common,
    only: [ csv_split: 1, ii: 2, keyss: 1 ]
  import PhxHttpWeb.View.Markup
  import PhxHttpWeb.View.Zoo

  alias InfoToml.Types, as: ITT
  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  Format an address for display.  If the address type (e.g., `:related`)
  is not found in the address map, return an empty string.

      iex> address  = %{
      iex>  web_site: %{
      iex>      main:    "https://anovaculinary.com/",
      iex>      product: "main|anova-precision-cooker"
      iex>    }
      iex>  }
      iex> fmt_address(:related,  address)
      ""
      iex> { :safe, io_list } = fmt_address(:web_site, address)
      iex> is_list(io_list)
      true
  """

  @spec fmt_address(atom, PHT.address) :: PHT.safe_html

  def fmt_address(section, address) do
    case address[section] do
      nil   -> ""
      map   -> fa1(section, map)
    end
  end

  # Private Functions

  @spec fa1(atom, ITT.item_part) :: PHT.safe_html

  # fmt_address helper functions: fa[123], fa2h
  #
  # fa1       add heading, generalize type
  # fa2       define a formatting function
  # fa3       format heading and list

  defp fa1(:document,   map),  do: fa2(:site, "Documents",          map)
  defp fa1(:email,      map),  do: fa2(:text, "Email Addresses",    map)
  defp fa1(:phone,      map),  do: fa2(:text, "Phone Numbers",      map)
  defp fa1(:postal,     map),  do: fa2(:post, "Postal Addresses",   map)
  defp fa1(:reference,  map),  do: fa2(:site, "References",         map)
  defp fa1(:related,    map),  do: fa2(:site, "Related Pages",      map)
  defp fa1(:review,     map),  do: fa2(:text, "Phone Numbers",      map)
  defp fa1(:web_site,   map),  do: fa2(:site, "Web Pages",          map)

  @spec fa2(atom, String.t, ITT.item_part) :: PHT.safe_html

  defp fa2(:post, heading, map) do

    item_fn = fn key ->
    #
    # Look up and format an item.

      lines   = String.replace(map[key], "\n", "<br>\n")
      [ "<li><b>#{ key }:</b><p> #{ lines }</p></li>" ]
    end

    fa3(heading, map, item_fn)
  end

  defp fa2(:site, heading, inp_map) do
    out_map = prep_map(inp_map)

    link_fn   = fn url ->
    #
    # Return the HTML for a single link.

      "[$url]{ #{ url } }" |> fmt_markup()
    end

    links_fn  = fn key ->
    #
    # Return the HTML for a set of links.

      links_raw   = out_map[key]    # "url, ..."
      |> csv_split()                # [ "url", ... ]

      links_cnt   = Enum.count(links_raw)

      links_rare  = links_raw
      |> Enum.map(link_fn)          # [ "<a href='url'>url</a>", ... ]
      |> Enum.sort()                # same, but sorted

      if false do #TG
        ii(links_cnt,  :links_cnt)
        ii(links_rare, :links_rare)
        ii(links_raw,  :links_raw)
      end
        
      if links_cnt == 1 do
        "<li><b>#{ fmt_key(key) }:</b> #{ links_rare }</li>"
      else
        links_out = links_rare
        |> Enum.join("</li>\n    <li>")

        """
        <li><b>#{ fmt_key(key) }:</b>
          <ul>
            <li>#{ links_out }</li>
          </ul>
        </li>\n
        """
      end
    end

    fa3(heading, out_map, links_fn)
  end

  defp fa2(:text, heading, map) do

    item_fn   = fn key -> [ "<li><b>#{ key }:</b> #{ map[key] }</li>" ] end
    #
    # Format the HTML for an item.

    fa3(heading, map, item_fn)
  end

  @spec fa3(st, map, (st -> [st]) ) :: PHT.safe_html
    when st: String.t

  defp fa3(heading, map, item_fn) do

    items = map                 # %{ main: url, ... }
    |> keyss()                  # [ :main, ... ]
    |> Enum.map(item_fn)        # [ "<li>...</li>", ... ]
    |> raw()                    # { :safe, [ "<li> ..." ] }

    ~E"""
    <h4><%= heading %></h4>
    <ul>
    <%= items %>
    </ul>
    """
  end

end
