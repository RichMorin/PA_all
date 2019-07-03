# phx_http_web/views/layout_view.ex

defmodule PhxHttpWeb.LayoutView do
#
# Public functions
#
#   get_title/4
#     Generate the (HTML HEAD) title string for the page.
#   key_field/2
#     Extract a field from the key, by position.
#   mailto_href/1
#     Generate the mailto href for the page footer.

  @moduledoc """
  This module supports rendering of the `layout` templates.
  """

  use Phoenix.HTML
  use PhxHttpWeb, :view

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
    if ssw(key, "_") do
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

end
