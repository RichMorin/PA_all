# phx_http_web/views/layout_view.ex

defmodule PhxHttpWeb.LayoutView do
#
# Public functions
#
#   get_title/4
#     Generate the (HTML HEAD) title string for the page.
#   hide_show/2
#     Wrap the hide_show_h/3 render call.
#   key_field/2
#     Extract a field from the key, by position.
#   mailto_href/1
#     Generate the mailto href for the page footer.
#
# Private Functions
#
#   hide_show_h/3
#     Render the appropriate `hs_*.html` file.

  @moduledoc """
  This module contains functions to format the overall page.
  """

  use Common.Types
  use Phoenix.HTML
  use PhxHttpWeb, :view
  use PhxHttp.Types

  alias  PhxHttpWeb.LayoutView

  # Public functions

  @doc """
  Generate the (HTML HEAD) title string for the page.

      iex> key    = "Areas/Catalog/_area.toml"
      iex> title  = "PA Areas"
      iex> get_title(:area_2, key, nil, title)
      "Catalog [PA Areas]"

      iex> key    = "Areas/Catalog/Hardware/_area.toml"
      iex> title  = "PA Areas"
      iex> get_title(:area_3, key, nil, title)
      "Hardware [PA Areas/Catalog]"

      iex> key    = "Areas/Catalog/Hardware/Anova_PC/main.toml"
      iex> item   = InfoToml.get_item(key)
      iex> title  = "PA Item"
      iex> get_title(:item, nil, item, title)
      "Anova Precision Cooker [PA Item]"

      iex> title  = "PA Item"
      iex> get_title(:edit_p, nil, nil, title)
      "Preview [PA Item]"

      iex> title  = "PA Foo"
      iex> get_title(:foo, nil, nil, title)
      "PA Foo"
  """

  @spec get_title(atom, any, any, s) :: s when s: String.t #W

  def get_title(:area_2, key, _item, title) do
    field_2   = key_field(key, -2)
    "#{ field_2 } [#{ title }]"
  end

  def get_title(:area_3, key, _item, title) do
    field_2   = key_field(key, -2)
    field_3   = key_field(key, -3)
    "#{ field_2 } [#{ title }/#{ field_3 }]"
  end

  def get_title(:item,      _key, item,  title) do
    "#{ item.meta.title } [#{ title }]"
  end

  def get_title(:source,     key, item,  title) do
    if String.starts_with?(key, "_") do
      "#{ key } [#{ title }]"
    else
      "#{ item.meta.title } [#{ title }]"
    end
  end

  def get_title(:edit_p,    _key, _item, title), do: "Preview [#{ title }]"
  def get_title(:search_c,  _key, _item, title), do: "Clear [#{ title }]"
  def get_title(:search_r,  _key, _item, title), do: "Report [#{ title }]"

  def get_title(_page_type, _key, _item, title), do: title
  #
  # Handle :area_1, :dash, :edit_[fs], :search_f, :text, etc.

  @doc """
  Wrap the hide_show render call.  The flag may be one of:

  - "ih:1/1", "is:1/1" - singleton
  - "ih:1/2", "is:1/2" - level 1 of 2
  - "ih:2/2", "is:2/2" - level 2 of 2

  The flag's prefix (`ih` or `is`) controls whether the body content
  is initially hidden or shown.  So, for example, "ih:1/1" produces
  a singleton (standalone) hide/show in which the body content is
  initially hidden.

      iex> { :safe, io_list } = hide_show("ih:1/1", "foo")
      iex> is_list(io_list)
      true

      iex> { :safe, io_list } = hide_show("foo", "bar")
      iex> io_list == "!!! invalid control string (foo). !!!"
      true
  """

  @spec hide_show(s, s) :: safe_html when s: String.t #W

  def hide_show("ih:1/1", t_str), do: hs("1", "s",     t_str)
  def hide_show("ih:1/2", t_str), do: hs("1", "s_sa",  t_str)
  def hide_show("ih:2/2", t_str), do: hs("2", "s",     t_str)
  def hide_show("is:1/1", t_str), do: hs("1", "h",     t_str)
  def hide_show("is:1/2", t_str), do: hs("1", "h_ha",  t_str)
  def hide_show("is:2/2", t_str), do: hs("2", "h",     t_str)

  def hide_show(bogon, _t_str) do
    message = "!!! invalid control string (#{ bogon }). !!!"
    { :safe, message }
  end

  @doc """
  Extract a field from the key, by position.

      iex> key = "Areas/Catalog/Hardware/_area.toml"
      iex> key_field(key, 0)
      "Areas"
      iex> key_field(key, -2)
      "Hardware"
      iex> key_field(key, -3)
      "Catalog"
  """

  @spec key_field(s, integer) :: s when s: String.t #W

  def key_field(key, index) do #K
    key
    |> String.split("/")
    |> Enum.fetch!(index)
  end

  @doc """
  Generate the mailto href for the page footer.

      iex> key  = "Areas/Catalog/Hardware/Anova_PC/main.toml"
      iex> href = mailto_href(key)
      iex> test = "mailto:Rich%20Morin%20%3Crdm@cfcl.com%3E?" <>
      iex>        "Subject=Pete's%20Alley%20feedback%20" <>
      iex>        "(Areas/Catalog/Hardware/Anova_PC/main.toml)"
      iex> href == test
      true
  """

  @spec mailto_href(s) :: s when s: String.t #W

  def mailto_href(item_key) do
    address   = "Rich Morin <rdm@cfcl.com>"
    subject   = "Pete's Alley feedback (#{ item_key })"
    combo     = "#{ address }?Subject=#{ subject }"

    "mailto:#{ URI.encode(combo) }"
  end

# Private Functions

  @spec hs(s, s, s) :: s when s: String.t #W

  defp hs(level, init_mode, inp_str) do
  #
  # Render the appropriate `hs_*.html` file.

    t_str   = inp_str <> ", ???" #K
    titles  = csv_split(t_str)

    assigns = %{
      hs_level:   level,
      hs_t1:      Enum.fetch!(titles, 0),
      hs_t2:      Enum.fetch!(titles, 1),
    }

    snip_url    = "_hs_#{ init_mode }.html"
    Phoenix.View.render(LayoutView, snip_url, assigns)
  end

end