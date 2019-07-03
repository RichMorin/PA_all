# phx_http_web/views/item_view.ex

defmodule PhxHttpWeb.ItemView do
#
# Public functions
#
#   fmt_address/2
#     Format an address for display.
#   fmt_key/1
#     Format the map key (handle special cases, then capitalize the rest).
#   fmt_review/1
#     Format a review for display.
#
# Private Functions
#
#   fa1/2
#     Helper function for fmt_address/2:  add heading, generalize type
#   fa2/3
#     Helper function for fa1/2:          define a formatting function
#   fa3/3
#     Helper function for fa2/3:          format heading and list
#   prep_map/1
#     Preprocess the input map.
#   prep_map_h/2
#     Preprocess an input string.

  @moduledoc """
  This module supports rendering of the `item` templates.
  """

  use Phoenix.HTML
  use PhxHttpWeb, :view

  import PhxHttpWeb.HideHelpers
  import InfoToml, only: [ exp_prefix: 1 ]

  alias PhxHttp.Types, as: PT

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

  @spec fmt_address(atom, PT.address) :: PT.safe_html #W

  def fmt_address(section, address) do
    case address[section] do
      nil   -> ""
      map   -> fa1(section, map)
    end
  end

  @doc """
  Format the map key (handle special cases, then capitalize the rest).

      iex> fmt_key(:faq)
      "FAQ"
      iex> fmt_key(:foo)
      "Foo"
  """

  @spec fmt_key(atom) :: String.t #W

  def fmt_key(:emacswiki),     do: "EmacsWiki"
  def fmt_key(:faq),           do: "FAQ"
  def fmt_key(:github),        do: "GitHub"
  def fmt_key(:gitlab),        do: "GitLab"
  def fmt_key(:google_p),      do: "Google+"
  def fmt_key(:irc),           do: "IRC"
  def fmt_key(:linked_in),     do: "LinkedIn"
  def fmt_key(:man_page),      do: "Manual Page"
  def fmt_key(:rubydoc),       do: "RubyDoc"
  def fmt_key(:rubygems),      do: "RubyGems"
  def fmt_key(:see_also),      do: "See Also"
  def fmt_key(:sourceforge),   do: "SourceForge"
  def fmt_key(:tty),           do: "TTY"
  def fmt_key(:web_site),      do: "Web Site"
  def fmt_key(:wordpress),     do: "WordPress"
  def fmt_key(:youtube),       do: "YouTube"
  def fmt_key(hdr_atom) do
    hdr_atom                    # :foo
    |> Atom.to_string()         # "foo"
    |> String.capitalize()      # "Foo"
  end

  @doc """
  Format a review for display.

      iex> rev_key  = "Areas/Catalog/Hardware/Anova_PC/text.Rich_Morin.toml"
      iex> { :safe, io_list } = fmt_review(rev_key)
      iex> is_list(io_list)
      true
  """

  @spec fmt_review(String.t) :: PT.safe_html #W

  def fmt_review(rev_key) do
    rev_item    = InfoToml.get_item(rev_key)
    f_authors   = rev_item.meta.refs.f_authors
    precis      = rev_item.about.precis
    verbose     = fmt_markdown(rev_item, [:about, :verbose])
    auth_out    = fmt_authors(f_authors)

    ~E"""
    <div class="hs-base2">
      <h4>
        <%= auth_out %>
        <%= hide_show("is:2/2", "full review for this item") %>
      </h4>
      <%= fmt_precis(precis) %>
      <div class="hs-body2">
        <%= verbose %>
      </div>
    </div>
    """
  end

  # Private Functions

  @spec fa1(atom, map) :: PT.safe_html #W

  # fmt_address helper functions: fa[123], fa2h
  #
  # fa1       add heading, generalize type
  # fa2       define a formatting function
  # fa3       format heading and list
  #
  # fmt_key   format the map key
  # prep_map  preprocess the input map

  defp fa1(:document,   map),  do: fa2(:site, "Documents",          map)
  defp fa1(:email,      map),  do: fa2(:text, "Email Addresses",    map)
  defp fa1(:phone,      map),  do: fa2(:text, "Phone Numbers",      map)
  defp fa1(:postal,     map),  do: fa2(:post, "Postal Addresses",   map)
  defp fa1(:reference,  map),  do: fa2(:site, "References",         map)
  defp fa1(:related,    map),  do: fa2(:site, "Related Pages",      map)
  defp fa1(:review,     map),  do: fa2(:text, "Phone Numbers",      map)
  defp fa1(:web_site,   map),  do: fa2(:site, "Web Pages",          map)

  @spec fa2(atom, String.t, map) :: PT.safe_html #W

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

    link_fn   = fn url -> "<a href='#{ url }'>#{ url }</a>" end
    #
    # Return the HTML for a single link.

    links_fn  = fn key ->
    #
    # Return the HTML for a set of links.

      links = out_map[key]      # "url, ..."
      |> csv_split()            # [ "url", ... ]
      |> Enum.map(link_fn)      # [ "<a href='url'>url</a>", ... ]

      if Enum.count(links) == 1 do
        "<li><b>#{ fmt_key(key) }:</b> #{ links }</li>"
      else
        links = links
        |> Enum.join("</li>\n    <li>")

        """
        <li><b>#{ fmt_key(key) }:</b>
          <ul>
            <li>#{ links }</li>
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

  @spec fa3(s, map, (s -> [ s ] ) ) :: PT.safe_html when s: String.t #W

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

  @spec prep_map(PT.addr_part) :: PT.addr_part #W

  defp prep_map(inp_map) do
  #
  # Preprocess the input map:
  #   expand global prefixes (eg, "ext_wp|")
  #   do one level of symbol substitution (eg, "main|...")
  #   remove entries with anonymous keys (eg, "_1").

    prep_fn     = fn field -> prep_map_h(field, inp_map) end
    #
    # Return the preprocessed field.

    reduce_fn   = fn {key, inp_val}, acc ->
    #
    # Build a map of preprocessed fields.

      out_val  = inp_val
      |> csv_split()
      |> Enum.map(prep_fn)
      |> Enum.join(", ")

      Map.put(acc, key, out_val)
    end

    ignore_fn   = fn {key, _val} -> "#{ key }" |> ssw("_") end
    #
    # Return true if the (stringified) key starts with an underscore.

    inp_map                         # %{ main: "https:...", ... }
    |> Enum.reject(ignore_fn)       # [ main: "https:...", ... ]
    |> Enum.reduce(%{}, reduce_fn)  # %{ main: "https:...", ... }
  end

  @spec prep_map_h(s, map) :: s when s: String.t #W

  defp prep_map_h(inp_val, inp_map) do
  #
  # Preprocess an input string:
  #   expand global prefixes (eg, "ext_wp|")
  #   do one level of symbol substitution (eg, "main|...")

    exp_val   = exp_prefix(inp_val)
    fields    = exp_val |> String.split("|")

    if Enum.count(fields) == 2 do
      [ pre_str, body] = fields
      pre_atom  = String.to_atom(pre_str)
      prefix    = inp_map[pre_atom]
      "#{ prefix }#{ body }"
    else
      exp_val
    end
  end

end
