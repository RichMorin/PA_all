# views/_link_helpers.ex

defmodule PhxHttpWeb.LinkHelpers do
#
# Public functions
#
#   do_links/1
#     Process links, as used in our flavor of Markdown.
#
# Private functions
#
#   do_links_h1/3
#     Handle links, dispatching based on their use of prefixes.
#   do_links_h2/3
#     Handle links, dispatching based on a derived "type" atom.

  @moduledoc """
  Handle transformation of our link syntax into vanilla Markdown, etc.
  """

  use Phoenix.HTML
  use PhxHttp.Types
  use InfoToml, :common
  use InfoToml.Types

  import Common

  # Note: There are bugs in Version 1.3.1 of Earmark (the Markdown engine).
  # We need to dance around these until their fixes are available in Hex.pm.
  # See `.../phx_http/mix.exs` for details.
  #
  #   Earmark does only render first link with a title of a line correctly.
  #   https://github.com/pragdave/earmark/issues/220
  #
  #   Handling of link title syntax gets confused
  #   https://github.com/pragdave/earmark/issues/224

  @doc """
  Transform links, as used in our flavor of Markdown, into vanilla syntax.
  Our extensions include:
  
  - elimination of all white space from URLs
  - trimming of white space from link text
  - generation of appropriate title strings
  - shorthand syntax for link URLs (e.g., `ext_gh`, `:a`)
  - shorthand syntax for link text (`$url`)

  Frequently referenced external sites, such as GitHub, get their own prefix
  (e.g., `ext_gh`) and a title suffix of `[site]`.

    iex> do_links("[Elixir]{ext_gh|foo/bar}")
    "[Elixir](https://github.com/foo/bar 'Go to: github.com [site]')"

    iex> do_links("[$url]{ext_gh|foo/bar}")
    "[https://github.com/foo/bar](https://github.com/foo/bar 'Go to: github.com [site]')"

    iex> do_links("[$url]{https://github.com}")
    "[https://github.com](https://github.com 'Go to: github.com [site]')"

    iex> do_links("[$url ]{https://  github.com}")
    "[https://github.com](https://github.com 'Go to: github.com [site]')"

  We use Wikipedia links a lot, mostly as a convenient way to define terms.
  So, we give it a title suffix of `[WP]`.
   
    iex> do_links("[Foo]{ext_wp|Foo}")
    "[Foo](https://en.wikipedia.org/wiki/Foo 'Go to: Foo [WP]')"

    iex> do_links("[Bar]{ext_wp|Bar_(baz)}")
    "[Bar](https://en.wikipedia.org/wiki/Bar_(baz) 'Go to: Bar (baz) [WP]')"

  Areas and items share a common set of prefixes (e.g., `cat`, `cat_gro`),
  but have distinct file names (e.g., `_area.toml`, `main.toml`) and title
  suffixes (e.g., `[area]`, `[item]`).

    iex> do_links("[Areas]{/Area}")
    "[Areas](/Area 'Go to: Areas [local]')"

    iex> do_links("[Catalog]{cat|:a}")
    "[Catalog](/area?key=Areas/Catalog/_area.toml 'Go to: Catalog [area]')"

    iex> do_links("[Groups]{cat_gro|:a}")
    "[Groups](/area?key=Areas/Catalog/Groups/_area.toml 'Go to: Groups [area]')"

    iex> do_links("[Test]{test|Me}")
    "[Test](/item?key=Test/Me/main.toml 'Go to: Test [item]')"

  The source code for item-related TOML files can be displayed as follows:

    iex> do_links("[Test]{test|Me:s}")
    "[Test](/source?key=Test/Me/main.toml 'Go to: Test [source]')"

  The source code for other TOML files can be displayed as follows:

    iex> do_links("[Prefix]{_config/prefix.toml:s}")
    "[Prefix](/source?key=_config/prefix.toml 'Go to: Prefix [source]')"

    iex> do_links("[About]{_text/about.toml:s}")
    "[About](/source?key=_text/about.toml 'Go to: About [source]')"

    iex> do_links("[Main Schema]{_schemas/main.toml:s}")
    "[Main Schema](/source?key=_schemas/main.toml 'Go to: Main Schema [source]')"

  The remaining local pages get the title suffix `[local]`.

    iex> do_links("[About]{_text/about.toml}")
    "[About](/text?key=_text/about.toml 'Go to: About [local]')"

    iex> do_links("[Dashboard]{/dash}")
    "[Dashboard](/dash 'Go to: Dashboard [local]')"

    iex> do_links("[Make Dashboard]{/dash/make}")
    "[Make Dashboard](/dash/make 'Go to: Make Dashboard [local]')"

    iex> do_links("[Search]{/search/find}")
    "[Search](/search/find 'Go to: Search [local]')"
  """

  @spec do_links(s) :: s when s: String.t #W

  def do_links(inp_str) do
    replace_fn  = fn _match, inp_1, inp_2 ->

      # Remove surrounding white space from the link text.
      # Remove all white space from the link URL.
      # Split the link URL into a list.

      trim_1  = String.trim(inp_1)
      trim_2  = String.replace(inp_2, ~r{\s}, "")
      list_2  = String.split(trim_2, "|")

      do_links_h1(trim_1, trim_2, list_2)
    end

    # Convert `[...]{...}`  syntax to `[...](...)` (support link extensions).
    # Convert `[...]!{...}` syntax to `[...]{...}` (support display in `pre`).

    pattern   = ~r< \[ ( [^\]]+ ) \]        # `[...]`
                    \{ ( [^\}]+ ) \} >x     # `{...}`

    Regex.replace(pattern, inp_str, replace_fn)
    |> String.replace("]!{", "]{")
  end

  # Private functions

  @spec do_links_h1(s, s, list) :: s when s: String.t #W

  defp do_links_h1(trim_1, trim_2, list_2 = [ head_2, tail_2 ]) do
  #
  # Handle links with prefixes.

    type    = cond do
      head_2 == "ext_wp"                ->  :ext_wp       # "ext_wp|..."
      head_2 =~ ~r{ ^ ext_ \w+ }x       ->  :ext_zoo      # "ext_...|..."
      String.ends_with?(tail_2, ":a")   ->  :int_area     # "...|:a"
      String.ends_with?(tail_2, ":s")   ->  :int_src1     # "...|...:s"
      true                              ->  :int_item     # "...|..."
    end

    _trace_fn  = fn out ->
      IO.puts ""
      ii(trim_1, "trim_1")
      ii(trim_2, "trim_2")
      ii(list_2, "list_2")
      ii(head_2, "head_2")
      ii(tail_2, "tail_2")
      ii(type,   "type")
      ii(out,    "out")
    end

    do_links_h2(type, trim_1, trim_2)
#   |> trace_fn.() #T
  end

  defp do_links_h1(trim_1, trim_2, list_2) do
  #
  # Handle links without prefixes.
  # Note that we don't have any current use case for `:local_u`.

    type    = cond do
      String.ends_with?(trim_2, ":s")         ->  :int_src2   # "...:s"
      String.starts_with?(trim_2, "/")        ->  :local_s    # "/..."
      String.starts_with?(trim_2, "_text/")   ->  :int_text   # "_text/..."
#     String.starts_with?(trim_2, "_")        ->  :local_u    # "_..."
      true                                    ->  :remote     # "..."
    end

    _trace_fn  = fn out ->
      IO.puts ""
      ii(trim_1, "trim_1")
      ii(trim_2, "trim_2")
      ii(list_2, "list_2")
      ii(type,   "type")
      ii(out,    "out")
    end

    do_links_h2(type, trim_1, trim_2)
#   |> trace_fn.() #T
  end

  @spec do_links_h2(atom, s, s) :: s when s: String.t #W

  defp do_links_h2(:ext_wp, inp_1, inp_2) do
  #
  # Handle external links to Wikipedia ("ext_wp|...").

    out_2   = exp_prefix(inp_2)
    out_1   = if inp_1 == "$url" do out_2 else inp_1 end

    tmp_2   = inp_2
    |> String.replace(~r{ ^ .* \| }x, "")   # eg, "Foo_bar#..."
    |> String.replace(~r{ \# .* $ }x, "")   # eg, "Foo_bar"
    |> String.replace(~r{ _ }x,      " ")   # eg, "Foo bar"

    title   = "Go to: #{ tmp_2 } [WP]"
    "[#{ out_1 }](#{ out_2 } '#{ title }')"
  end

  defp do_links_h2(:ext_zoo, inp_1, inp_2) do
  #
  # Handle other external links ("ext_...|...").

    out_2     = exp_prefix(inp_2)
    out_1     = if inp_1 == "$url" do out_2 else inp_1 end
    pattern   = ~r{ ^ .* // ( [^/]+ ) .* $ }x
    site      = String.replace(out_2, pattern, "\\1")
    title     = "Go to: #{ site } [site]"
    "[#{ out_1 }](#{ out_2 } '#{ title }')"
  end

  defp do_links_h2(:int_area, inp_1, inp_2) do
  #
  # Handle internal "area" links ("...|:a").

    out_2   = inp_2
    |> String.replace_trailing(":a", "")
    |> exp_prefix()

    title   = "Go to: #{ inp_1 } [area]"
    "[#{ inp_1 }](/area?key=#{ out_2 }_area.toml '#{ title }')"
  end

  defp do_links_h2(:int_item, inp_1, inp_2) do
  #
  # Handle internal "item" links ("...|...").

    out_2   = exp_prefix(inp_2)
    title   = "Go to: #{ inp_1 } [item]"
    "[#{ inp_1 }](/item?key=#{ out_2 }/main.toml '#{ title }')"
  end

  defp do_links_h2(:int_src1, inp_1, inp_2) do
  #
  # Handle expanded internal "source" links ("...|...:s").

    out_2   = inp_2
    |> String.replace_trailing(":s", "")
    |> exp_prefix()
    |> String.replace(~r{ ^ / (\w+) }x, "source")

    title   = "Go to: #{ inp_1 } [source]"
    "[#{ inp_1 }](/source?key=#{ out_2 }/main.toml '#{ title }')"
  end

  defp do_links_h2(:int_src2, inp_1, inp_2) do
  #
  # Handle unexpanded internal "source" links ("...:s").

    out_2   = inp_2
    |> String.replace_trailing(":s", "")
    |> exp_prefix()
    |> String.replace(~r{ ^ / (\w+) }x, "source")

    title   = "Go to: #{ inp_1 } [source]"
    "[#{ inp_1 }](/source?key=#{ out_2 } '#{ title }')"
  end

  defp do_links_h2(:int_text, inp_1, inp_2) do
  #
  # Handle internal "text" links ("_text/...").

    title   = "Go to: #{ inp_1 } [local]"
    "[#{ inp_1 }](/text?key=#{ inp_2 } '#{ title }')"
  end

  defp do_links_h2(:local_s, inp_1, inp_2) do
  #
  # Handle local links starting with slashes ("/...").

    title   = "Go to: #{ inp_1 } [local]"
    "[#{ inp_1 }](#{ inp_2 } '#{ title }')"
  end

  defp do_links_h2(:remote, inp_1, inp_2) do
  #
  # Handle remaining remote links ("...").

    out_1     = if inp_1 == "$url" do inp_2 else inp_1 end
    pattern   = ~r{ ^ .* // ( [^/]+ ) .* $ }x
    site      = String.replace(inp_2, pattern, "\\1")
    title     = "Go to: #{ site } [site]"
    "[#{ out_1 }](#{ inp_2 } '#{ title }')"
  end

#  defp do_links_h2(_type, inp_1, inp_2) do
#  #
#  # Handle remaining (bogus!) links.
#
#    title     = "Go to: #{ inp_2 } [???]"
#    "[#{ inp_1 }](#{ inp_2 } '#{ title }')"
#  end

end