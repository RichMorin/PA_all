# phx_http_web/views/search_view.ex

defmodule PhxHttpWeb.SearchView do
#
# Public functions
#
#   fmt_tag_set/3
#     Format a set of tags for display.
#   result_header/1
#     Generate header text for a result set.
#   result_url/1
#     Generate the URL text for a result.
#   tag_types/1
#     Generate a List of tag types for display.
#
# Private Functions
#
#   select/2
#     Generate HTML for a set of "Clear" or "Reuse" selection widgets.

  @moduledoc """
  This module contains functions to format parts of a Search page.
  """

  use Common.Types
  use Phoenix.HTML
  use PhxHttpWeb, :view
  use PhxHttp.Types

  import Common #D

  alias  PhxHttpWeb.LayoutView

  @doc """
  Format a set of tags for display.

      iex> tag_set  = [ "features:echolocation" ]
      iex> set_key  = "a"
      iex> settings = :reuse
      iex> { :safe, io_list } = fmt_tag_set(tag_set, set_key, settings)
      iex> io_str   = IO.iodata_to_binary(io_list)
      iex> test     = ~s(<div class="hs-base2">)
      iex> String.starts_with?(io_str, test)
      true
  """

  @spec fmt_tag_set(tag_set, String.t, atom) :: safe_html #W

  def fmt_tag_set(tag_set, set_key, settings) do
    chunk_fn  = fn [type, _val] -> type end 

    map_fn_1  = fn val -> String.split(val, ":") end

    map_fn_2  = fn chunk ->
      type  = chunk                 # [ ["f_authors", "Amanda_Lacy"], ...]
      |> hd()                       # ["f_authors", "Amanda_Lacy"]
      |> hd()                       # "f_authors"

      vals  = chunk                 
      |> Enum.map( &List.last/1 )   # ["Amanda_Lacy", "Rich_Morin"]
      |> Enum.join(", ")            # "Amanda_Lacy, Rich_Morin"

      "<li><b>#{ type }:</b> #{ vals }</li>"
    end

    set_str = tag_set           # [ "foo:ff", "bar:bb", ... ]
    |> Enum.sort()              # [ "bar:bb", "foo:ff", ... ]
    |> Enum.map(map_fn_1)       # [ [ "bar", "bb" ], ... ]
    |> Enum.chunk_by(chunk_fn)  # [ [ [ "bar", "bb" ], ... ], ... ]
    |> Enum.map(map_fn_2)       # [ "<li>...</li>", ... ]
    |> Enum.join("\n")          # "<li>...</li>\n..."
    |> raw()                    # { :safe, "<li>...</li>\n..." }

    header = case settings do
      :clear    ->
        "#{ select(:c, set_key) }&nbsp;<b>Query #{ set_key }</b>"
      :defined  ->
        "<b>Query #{ set_key }</b>"
      :reuse    ->
        "<b>Query #{ set_key }: </b> &nbsp; #{ select(:r, set_key) }"
      _         ->
        "<b>Query #{ set_key }: #{ settings }</b>"
    end |> raw()

    fmt_tag_set_h(settings, header, set_str)
  end

  @doc """
  Generate header text for a result set.

      iex> path     = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> results  = [ { path, "...", "..." } ]
      iex> result_header(results)
      {"Areas/Catalog", 1}
  """

  @spec result_header( [ {s, s, s} ] ) :: {s, integer} when s: String.t #W

  def result_header(results) do
    base_patt = ~r{ ^ ( \w+ / \w+ ) / .* $ }x
    base_fn   = fn path -> String.replace(path, base_patt, "\\1") end

    {path, _title, _precis} = List.first(results)
    count     = Enum.count(results)
    header    = base_fn.(path)
    {header, count}
  end

  @doc """
  Generate the URL text for a result.

      iex> item_key   = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> result_url(item_key)
      "/item?key=Areas/Catalog/People/Rich_Morin/main.toml"
  """

  @spec result_url(s) :: s when s: String.t #W

  def result_url(key), do: "/item?key=#{ key }"

  @doc """
  Generate a List of tag types for display.

      iex> kv_map = %{
      iex>   replaces: %{ "cutting board"   => 1 },
      iex>   requires: %{ "braille display" => 2 }
      iex> }
      iex> tag_types(kv_map)
      [:replaces]
  """

  @spec tag_types(tag_info) :: [ String.t ] #W

  def tag_types(kv_map) do
    exclude     = ~w(miscellany requires see_also)a #D - is this complete?
    reject_fn   = fn tag_type -> Enum.member?(exclude, tag_type) end

    kv_map
    |> keyss()
    |> Enum.reject(reject_fn)
  end

  # Private functions

  @spec fmt_tag_set_h(atom, t, t) :: t when t: tuple #W

  # Generate some HTML for `fmt_tag_set/3`.

  defp fmt_tag_set_h(:clear, header, set_str) do
    ~E"""
    <div class="hs-base2">
      <%= header %>
      <%= LayoutView.hide_show("ih:2/2", "details for this query") %>
      <div class="hs-body2 hs-ih">
        <ul><%= set_str %></ul>
      </div>
    </div>
    """
  end

  defp fmt_tag_set_h(_settings, header, set_str) do
    ~E"""
    <div class="hs-base2">
      <li>
        <%= header %>
        <%= LayoutView.hide_show("ih:2/2", "details for this query") %>
        <div class="hs-body2 hs-ih">
          <ul><%= set_str %></ul>
        </div>
      </li>
    </div>
    """
  end

  @spec select(atom, s) :: s when s: String.t #W

  defp select(:c, set_key) do
  #
  # Generate HTML for a set of "Clear" selection widgets.

    """
    <input type="checkbox" id="y_#{ set_key }"
           name="#{ set_key }" value="y">
    """
  end

  defp select(:r, set_key) do
  #
  # Generate HTML for a set of "Reuse" selection widgets.

    """
    <input type="radio" id="r_all_#{ set_key }"
           name="r_#{ set_key }" value="r:all">
    <label for="r_all_#{ set_key }">all</label> &nbsp;

    <input type="radio" id="r_any_#{ set_key }"
           name="r_#{ set_key }" value="r:any">
    <label for="r_any_#{ set_key }">any</label> &nbsp;

    <input type="radio" id="r_none_#{ set_key }"
           name="r_#{ set_key }" value="r:none" checked>
    <label for="r_none_#{ set_key }">none</label> &nbsp;
    """
  end

end
