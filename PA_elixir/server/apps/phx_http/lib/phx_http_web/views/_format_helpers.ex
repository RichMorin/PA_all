# views/_format_helpers.ex

defmodule PhxHttpWeb.FormatHelpers do
#
# Public functions
#
#   fmt_authors/1
#     Format author information, set up links, etc.
#   fmt_markdown/1
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
#   fmt_provide_h/2
#     Generic helper function for fmt_provide/2
#   join_list/1
#     Join a list of strings into a (mostly) comma-delimited string.
#   jl/[12]
#     Helper functions for join_list/1

  @moduledoc """
  Conveniences for formatting common page content.
  """

  alias PhxHttpWeb.{ItemView, LinkHelpers, PrefixHelpers}

  use Phoenix.HTML
  use PhxHttp.Types
  import Common

  @doc """
  This function formats author information, sets up links, etc.
  """

  @spec fmt_authors(String.t) :: safe_html

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
    |> str_list()             # [ "cat_peo|Rich_Morin", ... ]
    |> Enum.map(map_fn)       # [ <link to Rich_Morin's page>, ... ]
    |> join_list()            # "<link1>, <link2>, and ..."
    |> wrap_fn.()             # "by <link>, ..."
    |> raw()                  # { :safe, "by <link>, ..." }
  end

  @doc """
  This function converts Markdown to HTML.  In the process, it expands some
  prefix strings.
  """

  @spec fmt_markdown(String.t) :: safe_html

  def fmt_markdown(md_inp) do
    md_exp  = LinkHelpers.do_links(md_inp)

    fmt_fn  = fn {type, ndx, text} -> 
        "<p>#{ type } (#{ ndx }): #{ text }</p>"
    end

    case Earmark.as_html(md_exp) do
      {:ok, html, []} -> html

      {:error, _input, err_list} ->
        err_list                  # [ {:warning, 1, "..."}, ... ]
        |> Enum.map(fmt_fn)       # [ "<p>warning (1): ...</p>", ... ]
        |> Enum.join(",<br>\n")   # "<p>warning (1): ...</p>,<br>\n..."

#     unknown -> "<p>#{ inspect(unknown) }</p>"   #D
    end |> raw()
  end

  @doc """
  This function formats the file path for display.
  """

  @spec fmt_path(String.t) :: safe_html

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

  @spec fmt_precis(String.t) :: safe_html

  def fmt_precis(precis) do
    "<p><b>Precis:</b>&nbsp; #{ precis }</p>" |> raw()
  end

  @doc """
  This function formats a reference from `meta.refs.*`.
  """

  @spec fmt_ref(atom, map) :: {}

  def fmt_ref(ref_key, ref_val) do
    label     = ItemView.fmt_key(ref_key)

    map_fn1   = fn in_item -> 
      key       = "#{ in_item }/main.toml"
      |> PrefixHelpers.exp_prefix()

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
    |> str_list()             # [ "cat_sof|F123_Access", ... ]
    |> Enum.map(map_fn1)      # [ {<link>, <title>}, ... ]
    |> Enum.sort_by(sort_fn)  # ditto, but sorted by title
    |> Enum.map(map_fn2)      # [ <link>, ... ]
    |> join_list()            # "<link>, <link>, and ..."
    |> wrap_fn.()             # "<label>: <link>, ..."
    |> raw()
  end

  @doc """
  This function extracts and sorts the keys from a `tag_sets` stucture.

      iex> ts = %{ "b" => 3, "ab" => 2, "a" => 1 }
      iex> sort_keys(ts)
      [ "a", "ab", "b" ]
  """

  @spec sort_keys(tag_sets) :: [ String.t ]

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

  @spec join_list( [ s ] ) :: s when s: String.t

  defp join_list(a),       do: jl(a)
  #
  # Join a list of strings into a (mostly) comma-delimited string.
  # Include "and" where appropriate. 
  #
  # Note: If and when we internationalize the site, we might want to
  # to consider using Cldr (https://github.com/kipcole9/cldr) for
  # this sort of thing (specifically, cldr_lists).  Finally, anyone
  # who is interested in this as a programming challenge should visit
  # the Elixir Forum topic Rich started: https://elixirforum.com/t/
  #   formatting-a-list-of-strings-am-i-missing-anything/18593/10
  # Interesting discussion and really great help!

  @spec jl(list) :: String.t

  defp jl([]),            do: ""
  defp jl([a]),           do: "#{ a }"
  defp jl([a, b]),        do: "#{ a } and #{ b }"
  defp jl(list),          do: jl(list, [])

  @spec jl(list, [ String.t ] ) :: String.t

  defp jl([last], strl),  do: to_string( [ strl, 'and ', "#{ last }" ] )
  defp jl([h | t], strl), do: jl(t, [ strl, "#{ h }", ', '] )

end