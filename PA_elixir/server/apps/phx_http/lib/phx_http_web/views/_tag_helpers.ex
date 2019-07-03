# phx_http_web/views/_tag_helpers.ex

defmodule PhxHttpWeb.TagHelpers do
#
# Public functions
#
#   fmt_tag_set/3
#     Format a set of tags for display.
#   tag_types/1
#     Generate a list of tag types for display.
#
# Private Functions
#
#   fmt_tag_set_h/3
#     Generate some HTML for `fmt_tag_set/3`.
#   select/2
#     Generate HTML for a set of "Clear" or "Reuse" selection widgets.

  @moduledoc """
  Handle formatting of tag sets for `ClearView` and `SearchView`.
  """

  use Phoenix.HTML

  import Common, only: [ keyss: 1 ]
  import PhxHttpWeb.HideHelpers

  alias PhxHttp.Types, as: PT

  # Public functions

  @doc """
  Format a set of tags for display.

      iex> tag_set  = [ "features:echolocation" ]
      iex> set_key  = "a"
      iex> settings = :reuse
      iex> { :safe, io_list } = fmt_tag_set(tag_set, set_key, settings)
      iex> io_str   = IO.iodata_to_binary(io_list)
      iex> test     = ~s(<div class="hs-base2">)
      iex> ssw(io_str, test)
      true
  """

  @spec fmt_tag_set(PT.tag_set, String.t, atom) :: PT.safe_html #W

  def fmt_tag_set(tag_set, set_key, settings) do

    type_fn  = fn [type, _val] -> type end 
    #
    # Support chunking by type.

    split_fn  = fn field -> String.split(field, ":") end
    #
    # Split the tag field into type and tag values.

    fmt_fn  = fn chunk ->
    #
    # Format a chunk as HTML.

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
    |> Enum.map(split_fn)       # [ [ "bar", "bb" ], ... ]
    |> Enum.chunk_by(type_fn)   # [ [ [ "bar", "bb" ], ... ], ... ]
    |> Enum.map(fmt_fn)         # [ "<li>...</li>", ... ]
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
  Generate a list of tag types for display.

      iex> kv_map = %{
      iex>   replaces: %{ "cutting board"   => 1 },
      iex>   requires: %{ "braille display" => 2 }
      iex> }
      iex> tag_types(kv_map)
      [:replaces, :requires]
  """

  @spec tag_types(PT.tag_info) :: [ String.t ] #W

  def tag_types(kv_map) do
#   exclude     = ~w(miscellany requires see_also)a #D
    exclude     = ~w( )a

    exclude_fn  = fn tag_type -> Enum.member?(exclude, tag_type) end
    #
    # Return true if the tag type is present in the exclude list.

    kv_map
    |> keyss()
    |> Enum.reject(exclude_fn)
  end

  # Private functions

  @spec fmt_tag_set_h(atom, t, t) :: t when t: tuple #W

  # Generate some HTML for `fmt_tag_set/3`.

  defp fmt_tag_set_h(:clear, header, set_str) do
    ~E"""
    <div class="hs-base2">
      <%= header %>
      <%= hide_show("ih:2/2", "details for this query") %>
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
        <%= hide_show("ih:2/2", "details for this query") %>
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
