# phx_http_web/views/_format_helpers.ex

defmodule PhxHttpWeb.FormatHelpers do
#
# Public functions
#
#   fmt_authors/1
#     Format author information, set up links, etc.
#   fmt_markdown/2
#     Convert Markdown to HTML.
#   fmt_path/1
#     Format the file path for display.
#   fmt_precis/1
#     Format `about.precis` in a consistent manner.
#   fmt_ref/2
#     Format a reference from `meta.refs.*`.
#   sort_keys/2
#    Extract and sort the keys from a `tag_sets` stucture.
#
# Private functions
#
#   fmt_markdown_h/3
#     Format error text for fmt_markdown/2.

  @moduledoc """
  Conveniences for formatting common page content.
  """

  use Phoenix.HTML
  use PhxHttp.Types

  import Common, only: [ csv_join: 1, csv_split: 1 ]

  alias PhxHttpWeb.{ItemView, LinkHelpers}

  # Public functions

  @doc """
  This function formats author information, sets up links, etc.
  """

  @spec fmt_authors(String.t) :: safe_html #W

  def fmt_authors(f_authors) do

    map_fn  = fn ref_str ->
      id_str  = String.replace_prefix(ref_str, "cat_peo|", "")
      key     = "Areas/Catalog/People/#{ id_str }/main.toml"
      href    = "/item?key=#{ key }"
      name    = InfoToml.get_item(key).meta.title

      """
      <a href='#{ href }'
         title="Go to #{ name }'s page"
        >#{ name }</a>
      """
    end

    wrap_fn = fn line -> "by\n#{ line }" end

    f_authors                 # "cat_peo|Rich_Morin, ..."
    |> csv_split()            # [ "cat_peo|Rich_Morin", ... ]
    |> Enum.map(map_fn)       # [ <link to Rich_Morin's page>, ... ]
    |> csv_join()             # "<link1>, <link2>, and ..."
    |> wrap_fn.()             # "by <link>, ..."
    |> raw()                  # { :safe, "by <link>, ..." }
  end

  @doc """
  This function converts Markdown to HTML.  In the process, it expands some
  prefix strings.
  """

  @spec fmt_markdown(map, [atom]) :: safe_html #W

  def fmt_markdown(inp_map, gi_list) do
    md_inp  = get_in(inp_map, gi_list)
    md_exp  = LinkHelpers.do_links(md_inp)

    case Earmark.as_html(md_exp) do
      {:ok, html, []} -> html

      {:error, _input, err_list} ->
        fmt_markdown_h(inp_map, gi_list, err_list)

#     unknown -> "<p>#{ inspect(unknown) }</p>"   #D
    end |> raw()
  end

  @doc """
  This function formats the file path for display.
  """

  @spec fmt_path(String.t) :: safe_html #W

  def fmt_path(key) do
    # Generates three links of these forms:
    #   /area
    #   /area?key=Areas/Catalog/_area.toml
    #   /area?key=Areas/Catalog/Groups/_area.toml

    nodes   = key           # "Areas/Catalog/Groups/F123/main.toml"
    |> String.split("/")    # [ "Areas", "Catalog", ... ]
    |> Enum.slice(1..2)     # [ "Catalog", "Groups" ]

    t1      = nodes |> hd()
    t2      = nodes |> Enum.join("/")

    href    = fn x -> "/area?key=Areas/#{ x }/_area.toml" end
    title   = fn x -> "Go to the #{ x } index page." end

    common  = """
    <b>Path:</b>&nbsp;
    <a href="/area"
      title="#{ title.("Areas") }"
      >Areas</a>,&nbsp;
    """

    extras  = if String.ends_with?(key, "/_area.toml") do
      """
      <a href="#{ href.(t1) }"
         title="#{ title.("Areas/" <> t1) }"
        >#{ hd(nodes) }</a>
      """
    else
      """
      <a href="#{ href.(t1) }"
         title="#{ title.("Areas/" <> t1) }"
        >#{ hd(nodes) }</a>,&nbsp;
      <a href="#{ href.(t2) }"
         title="#{ title.("Areas/" <> t2) }"
        >#{ tl(nodes) }</a>
      """
    end

    (common <> extras) |> raw()
  end

  @doc """
  This function formats `about.precis` in a consistent manner.

      iex> p = "precis"
      iex> fmt_precis(p)
      { :safe, "<p><b>Precis:</b>&nbsp; precis</p>" }
  """

  @spec fmt_precis(String.t) :: safe_html #W

  def fmt_precis(precis) do
    "<p><b>Precis:</b>&nbsp; #{ precis }</p>" |> raw()
  end

  @doc """
  This function formats a reference from `meta.refs.*`.
  """

  @spec fmt_ref(atom, String.t) :: tuple #W

  def fmt_ref(ref_key, ref_val) do
    label     = ItemView.fmt_key(ref_key)

    map_fn1   = fn in_item -> 
      key       = "#{ in_item }/main.toml" |> InfoToml.exp_prefix()
      href      = "/item?key=#{ key }"
      link_text = InfoToml.get_item(key).meta.title
      title     = "Go to: #{ label } page"

      link      = """
      <a href='#{ href }' title='#{ title }'>#{ link_text }</a>
      """

      {link, title}
    end

    map_fn2   = fn {link, _title} -> link end
    sort_fn   = fn {_link, title} -> title end
    wrap_fn   = fn link_str -> "<b>#{ label }:</b>&nbsp; #{ link_str }" end

    ref_val                   # "cat_sof|F123_Access, ..."
    |> csv_split()            # [ "cat_sof|F123_Access", ... ]
    |> Enum.map(map_fn1)      # [ {<link>, <title>}, ... ]
    |> Enum.sort_by(sort_fn)  # ditto, but sorted by title
    |> Enum.map(map_fn2)      # [ <link>, ... ]
    |> csv_join()             # "<link>, <link>, and ..."
    |> wrap_fn.()             # "<label>: <link>, ..."
    |> raw()
  end

  @doc """
  This function extracts and sorts the keys from a `tag_sets` stucture.

      iex> ts = %{ "b" => 3, "ab" => 2, "a" => 1 }
      iex> sort_keys(ts)
      [ "a", "ab", "b" ]
  """

  @spec sort_keys(tag_sets) :: [ String.t ] #W

  def sort_keys(tag_sets) do
    letters = ~w(a b c d e f g h i j k l m n o p q r s t u v w x y z)

    reduce_fn   = fn (char, acc) ->
      find_fn   = fn c -> c == char end
      ndx       = Enum.find_index(letters, find_fn)
      acc * 26 + ndx
    end

    sort_fn   = fn inp_str ->
      inp_str                         # "aa"
      |> String.graphemes()           # [ "a", "a" ]
      |> Enum.reduce(0, reduce_fn)    # 27
    end

    tag_sets                          # %{ "aa" => [...], "z" => [...], ... }
    |> Map.keys()                     # [ "aa", "z", ... ]
    |> Enum.sort_by(sort_fn)          # [ "z", "aa", ... ]
  end

  # Private Functions

  @spec fmt_markdown_h(map, [atom], list) :: String.t

  defp fmt_markdown_h(inp_map, gi_list, err_list) do
  #
  # Format error text for fmt_markdown/2.

    last_key  = List.last(gi_list)
    off_key   = "o_#{ last_key }" |> String.to_atom()

    off_int   = inp_map
    |> get_in([:meta, off_key])
    |> String.to_integer()
    
    fmt_fn  = fn {type, ndx_raw, message} -> 

      ndx_rare    = ndx_raw + off_int

      line_text   = inp_map
      |> get_in(gi_list)
      |> String.split("\n")
      |> Enum.fetch!(ndx_raw-2)

      """
      <p>
        <b>Earmark #{ type }:</b>
        <pre>
          diagnostic:   "#{ message }"
          get_in list:  #{ inspect(gi_list) }
          line number:  #{ ndx_rare }
          line text:    "#{ line_text }"</pre>
      </p>
      """
    end

    err_list             # [ {:warning, 1, "..."}, ... ]
    |> Enum.map(fmt_fn)  # [ "<p>...</p>", ... ]
    |> Enum.join("\n")   # "<p>...</p>\n..."
  end

end