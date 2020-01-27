# phx_http_web/views/_link.ex

defmodule PhxHttpWeb.View.Link do
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

  import Common,   only: [ ii: 2, sew: 2, ssw: 2 ]
  import InfoToml, only: [ exp_prefix: 1 ]

  alias PhxHttp.Types, as: PHT

  # Note: There are bugs in Version 1.3.1 of Earmark (the Markdown engine).
  # We need to dance around these until their fixes are available in Hex.pm.
  # See `.../phx_http/mix.exs` for details.
  #
  #   Earmark does only render first link with a title of a line correctly.
  #   https://github.com/pragdave/earmark/issues/220
  #
  #   Handling of link title syntax gets confused
  #   https://github.com/pragdave/earmark/issues/224

  # Public functions

  @doc """
  Transform links, as used in our flavor of Markdown, into vanilla syntax.
  Our extensions include:
  
  - elimination of all white space from URLs
  - trimming of white space from link text
  - shorthand syntax for link URLs (e.g., `ext_gh`, `:a`)
  - shorthand syntax for link text (`$url`)

  Areas and items share a common set of prefixes (e.g., `cat`, `cat_gro`),
  but have distinct file names (e.g., `_area.toml`, `main.toml`).

      iex> do_links("[Areas]{/Area}")
      "[Areas](/Area)"

      iex> do_links("[Catalog]{cat|:a}")
      "[Catalog](/area?key=Areas/Catalog/_area.toml)"

      iex> do_links("[Groups]{cat_gro|:a}")
      "[Groups](/area?key=Areas/Catalog/Groups/_area.toml)"

      iex> do_links("[A1]{cat_gro|A2}")
      "[A1](/item?key=Areas/Catalog/Groups/A2/main.toml)"

  The source code for item-related TOML files can be displayed as follows:

      iex> do_links("[A1]{cat_gro|A2:s}")
      "[A1](/source?key=Areas/Catalog/Groups/A2/main.toml)"

  The source code for other TOML files can be displayed as follows:

      iex> do_links("[Prefix]{_config/prefix.toml:s}")
      "[Prefix](/source?key=_config/prefix.toml)"

      iex> do_links("[About]{_text/about.toml:s}")
      "[About](/source?key=_text/about.toml)"

      iex> do_links("[Main Schema]{_schemas/main.toml:s}")
      "[Main Schema](/source?key=_schemas/main.toml)"
  """

  @spec do_links(st) :: st
    when st: String.t

  def do_links(inp_str) do

    expand_fn   = fn _match, inp_1, inp_2 ->
    #
    # Return the expanded form of the link.

      # Remove surrounding white space from the link text.
      # Remove all white space from the link URL.
      # Split the link URL into a list.
      # Generate the conventional form of the link.

      trim_1  = String.trim(inp_1)
      trim_2  = String.replace(inp_2, ~r{\s}, "")

      s_pair  = trim_2
      |> String.split("|")
      |> List.to_tuple()

      do_links_h1(trim_1, trim_2, s_pair)
    end

    #!K Preprocess A$...$ inclusions (in Perkify_Pkg_List).
    
    pattern     = ~r{A\$([-\w+]+)\$}
    pre_base    = "https://packages.ubuntu.com"
    pre_full    = "#{ pre_base }eoan"
    becomes     = "[\\1]{#{ pre_full }/\\1}"
    tmp_str     = inp_str |> String.replace(pattern, becomes)

    # Convert `[...]{...}`  syntax to `[...](...)` (support link extensions).
    # Convert `[...]!{...}` syntax to `[...]{...}` (support display in `pre`).

    pattern   = ~r< \[ ( [^\]]+ ) \]        # `[...]`
                    \{ ( [^\}]+ ) \} >x     # `{...}`

    Regex.replace(pattern, tmp_str, expand_fn)
    |> String.replace("]!{", "]{")
  end

  # Private functions

  @spec do_links_h1(st, st, PHT.s_pair) :: st
    when st: String.t

  defp do_links_h1(trim_1, trim_2, {head_2, tail_2}) do
  #
  # Handle links with prefixes.
  #
  #!K - Routine must be edited if a new Area is added.

    type    = cond do
      head_2 =~ ~r{ ^ (cat|con) }x ->
        cond do
          sew(tail_2, ":a")   ->  :int_area     # "...|:a"
          sew(tail_2, ":s")   ->  :int_src1     # "...|...:s"
          true                ->  :int_item     # "...|..."
        end

      head_2 == "ext_wp"  ->  :ext_wp       # "ext_wp|..."
      true                ->  :ext_zoo      # "..._...|..."  
    end

    do_links_h2(type, trim_1, trim_2)
  end

  defp do_links_h1(trim_1, trim_2, _list_2) do
  #
  # Handle links without prefixes.
  # Note that we don't have any current use case for `:local_u`.

    type    = cond do
      String.ends_with?(  trim_2, ":s")       ->  :int_src2   # "...:s"
      ssw(trim_2, "/")        ->  :local_s    # "/..."
      ssw(trim_2, "_text/")   ->  :int_text   # "_text/..."
#     ssw(trim_2, "_")        ->  :local_u    # "_..."
      true                                    ->  :remote     # "..."
    end

    do_links_h2(type, trim_1, trim_2)
  end

  @spec do_links_h2(atom, st, st) :: st
    when st: String.t

  defp do_links_h2(:ext_wp, inp_1, inp_2) do
  #
  # Handle external links to Wikipedia ("ext_wp|...").

    out_2   = exp_prefix(inp_2)
    out_1   = if inp_1 == "$url" do out_2 else inp_1 end

    "[#{ out_1 }](#{ out_2 })"
  end

  defp do_links_h2(:ext_zoo, inp_1, inp_2) do
  #
  # Handle other external links ("ext_...|...").

    out_2     = exp_prefix(inp_2)
    out_1     = if inp_1 == "$url" do out_2 else inp_1 end

    "[#{ out_1 }](#{ out_2 })"
  end

  defp do_links_h2(:int_area, inp_1, inp_2) do
  #
  # Handle internal "area" links ("...|:a").

    out_2   = inp_2
    |> String.replace_trailing(":a", "")
    |> exp_prefix()

    "[#{ inp_1 }](/area?key=#{ out_2 }_area.toml)"
  end

  defp do_links_h2(:int_item, inp_1, inp_2) do
  #
  # Handle internal "item" links ("...|...").

    out_2   = exp_prefix(inp_2)

    "[#{ inp_1 }](/item?key=#{ out_2 }/main.toml)"
  end

  defp do_links_h2(:int_src1, inp_1, inp_2) do
  #
  # Handle expanded internal "source" links ("...|...:s").

    out_2   = inp_2
    |> String.replace_trailing(":s", "")
    |> exp_prefix()
    |> String.replace(~r{ ^ / (\w+) }x, "source")

    "[#{ inp_1 }](/source?key=#{ out_2 }/main.toml)"
  end

  defp do_links_h2(:int_src2, inp_1, inp_2) do
  #
  # Handle unexpanded internal "source" links ("...:s").

    out_2   = inp_2
    |> String.replace_trailing(":s", "")
    |> exp_prefix()
    |> String.replace(~r{ ^ / (\w+) }x, "source")

    "[#{ inp_1 }](/source?key=#{ out_2 })"
  end

  defp do_links_h2(:int_text, inp_1, inp_2) do
  #
  # Handle internal "text" links ("_text/...").

    "[#{ inp_1 }](/text?key=#{ inp_2 })"
  end

  defp do_links_h2(:local_s, inp_1, inp_2) do
  #
  # Handle local links starting with slashes ("/...").

    "[#{ inp_1 }](#{ inp_2 })"
  end

  defp do_links_h2(:remote, inp_1, inp_2) do
  #
  # Handle remaining remote links ("...").

    out_1     = if inp_1 == "$url" do inp_2 else inp_1 end

    "[#{ out_1 }](#{ inp_2 })"
  end

end