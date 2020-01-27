# phx_http_web/views/_format.ex

defmodule PhxHttpWeb.View.Format do
#
# Public functions
#
#   fmt_authors/1
#     Format author information, set up links, etc.
#   fmt_path/1
#     Format the file path for display.
#   fmt_precis/1
#     Format `about.precis` in a consistent manner.
#   fmt_ref/2
#     Format a reference from `meta.refs.*`.
#   sort_keys/2
#    Extract and sort the keys from a `tag_sets` stucture.

  @moduledoc """
  Conveniences for formatting common page content.
  """

  use Phoenix.HTML

  import Common,
    only: [ fmt_list: 1, csv_split: 1, sort_by_elem: 3 ]
  import PhxHttpWeb.View.Zoo,
    only: [ fmt_key: 1 ]

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  This function formats author information, sets up links, etc.
  """

  @spec fmt_authors(String.t) :: PHT.safe_html

  def fmt_authors(f_authors) do

    link_fn  = fn ref_str ->
    #
    # Return the HTML for a link, based on the reference string.

      id_str  = String.replace_prefix(ref_str, "cat_peo|", "")
      key     = "Areas/Catalog/People/#{ id_str }/main.toml"
      href    = "/item?key=#{ key }"
      name    = InfoToml.get_item(key).meta.title

      """
      <a href='#{ href }'
        >#{ name }</a>
      """
    end

    byline_fn   = fn line -> "by\n#{ line }" end
    #
    # Return the HTML for a byline.

    f_authors                 # "cat_peo|Rich_Morin, ..."
    |> csv_split()            # [ "cat_peo|Rich_Morin", ... ]
    |> Enum.map(link_fn)      # [ <link to Rich_Morin's page>, ... ]
    |> fmt_list()             # "<link1>, <link2>, and ..."
    |> byline_fn.()           # "by <link>, ..."
    |> raw()                  # { :safe, "by <link>, ..." }
  end

  @doc """
  This function formats the file path for display.
  """

  @spec fmt_path(String.t) :: PHT.safe_html

  def fmt_path(key) do
    # Generates three links of these forms:
    #   /area
    #   /area?key=Areas/Catalog/_area.toml
    #   /area?key=Areas/Catalog/Groups/_area.toml

    nodes   = key           # "Areas/Catalog/Groups/VOISS/main.toml"
    |> String.split("/")    # [ "Areas", "Catalog", ... ]
    |> Enum.slice(1..2)     # [ "Catalog", "Groups" ]

    t1        = nodes |> hd()
    t2        = nodes |> Enum.join("/")

    href_fn   = fn area ->
    #
    # Return the URL for an area href.

      "/area?key=Areas/#{ area }/_area.toml"
    end

    common  = """
    <div class="no_print">
      <b>Path:</b>&nbsp;
      <a href="/area">Areas</a>,&nbsp;
    """

    extras  = if String.ends_with?(key, "/_area.toml") do
      """
        <a href="#{ href_fn.(t1) }">#{ hd(nodes) }</a>
      """
    else
      """
        <a href="#{ href_fn.(t1) }">#{ hd(nodes) }</a>,&nbsp;
        <a href="#{ href_fn.(t2) }">#{ tl(nodes) }</a>
      """
    end <> "</div>\n"

    (common <> extras) |> raw()
  end

  @doc """
  This function formats `about.precis` in a consistent manner.

      iex> p = "precis"
      iex> fmt_precis(p)
      { :safe, "<p><b>Precis:</b>&nbsp; precis</p>" }
  """

  @spec fmt_precis(String.t) :: PHT.safe_html

  def fmt_precis(precis) do
    "<p><b>Precis:</b>&nbsp; #{ precis }</p>\n<pa_toc />\n" |> raw()
  end

  @doc """
  This function formats one or more references from `meta.refs.*`.
  """

  @spec fmt_ref(atom, String.t) :: tuple #!V - tuple
# @spec fmt_ref(atom, st) :: {st, PHT.safe_html}
#   when st: String.t # breaks!

  def fmt_ref(ref_key, ref_val) do
    label         = fmt_key(ref_key)

    tuple_fn      = fn in_item ->
    #
    # Return the link HTML and the link text, in a tuple.
 
      key         = "#{ in_item }/main.toml" |> InfoToml.exp_prefix()
      href        = "/item?key=#{ key }"
      link_text   = InfoToml.get_item(key).meta.title
      link        = "<a href='#{ href }'>#{ link_text }</a>"

      {link, link_text}
    end

    link_fn   = fn {link, _title} -> link  end

    wrap_fn   = fn link_str ->
    #
    # Wrap the link HTML with a label, etc. 

      "<b>#{ label }:</b>&nbsp; #{ link_str }"
    end

    ref_val                     # "cat_ser|F123_Access, ..."
    |> csv_split()              # [ "cat_ser|F123_Access", ... ]
    |> Enum.map(tuple_fn)       # [ {<link>, <link_text>}, ... ]
    |> sort_by_elem(1, :dc)     # ditto, but sorted by link text
    |> Enum.map(link_fn)        # [ <link>, ... ]
    |> fmt_list()               # "<link>, <link>, and ..."
    |> wrap_fn.()               # "<label>: <link>, ..."
    |> raw()                    # { :safe, "<label>: <link>, ..." }
  end

  @doc """
  This function extracts and sorts the keys from a `tag_sets` stucture.

      iex> ts = %{ "b" => 3, "ab" => 2, "a" => 1 }
      iex> sort_keys(ts)
      [ "a", "ab", "b" ]
  """

  @spec sort_keys(PHT.tag_sets) :: [String.t]

  def sort_keys(tag_sets) do
    letters = ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    base26_fn   = fn char, acc ->
    #
    # Accumulate a base-26 index (of sorts) from a list of graphemes.
    # That is, add each letter value (0-25) to its position value
    # (eg, 0, 26).

      match_fn  = fn c -> c == char end
      #
      # Return true if char matches this point in the letters list.

      ndx       = Enum.find_index(letters, match_fn)
      acc * 26 + ndx
    end

    sort_fn   = fn inp_str ->
    #
    # Support sorting by a-z, aa-zz, etc.

      inp_str                         # "aa"
      |> String.graphemes()           # [ "a", "a" ]
      |> Enum.reduce(0, base26_fn)    # 27
    end

    tag_sets                          # %{ "aa" => [...], "z" => [...], ... }
    |> Map.keys()                     # [ "aa", "z", ... ]
    |> Enum.sort_by(sort_fn)          # [ "z", "aa", ... ]
  end

end