# phx_http_web/router_toc.ex

defmodule PhxHttpWeb.Router.TOC do
#
# The registration approach taken by this module plug is loosely inspired
# by MinifyResponse (https://github.com/gravityblast/minify_response).
#
# Public Functions
#
#   add/1         add a Table of Contents to the (HTML) output page
#   call/2        registers TOC.add/1
#   init/1        required by module plug API (noop)
#
# Private Functions
#
#   edit_body/2   edit the body of the output page
#   get_level/1   generate a level from a header
#   get_name/1    generate a name from an index value
#   get_toc/1     generate TOC HTML from the match_list
#
# Written by Rich Morin, CFCL, 2020.

  @moduledoc """
  The `TOC` plug adds a table of contents to the response body when:

  - the response content type is `text/html`
  - it finds a `<toc />` element in the page

  The following line goes near the end of `pipeline :browser` in `router.ex`.

  ```
  plug PhxHttpWeb.Router.TOC
  ```
  """

  import Common, warn: false, only: [ii: 2]

  alias PhxHttpWeb.Router.TOC

  # Public Functions

  @doc """
  If the output `content-type` is `text/html`, call `edit_body/1`
  and put the result into the output `conn` structure.
  Otherwise, just return the input `conn` structure.
  """

  @spec add(pc) :: pc
    when pc: Plug.Conn.t

  def add(conn) do

    case List.keyfind(conn.resp_headers, "content-type", 0) do
      {_, "text/html" <> _} ->
        resp_body   = conn.resp_body |> edit_body()
        %Plug.Conn{conn | resp_body: resp_body}

      _ -> conn
    end
  end

  @doc """
  This function registers `TOC.add/1` to be called before any output is sent.
  """

  @spec call(pc, any) :: pc
    when pc: Plug.Conn.t

  def call(conn, _opts) do
    Plug.Conn.register_before_send(conn, &TOC.add/1)
  end

  @doc """
  This plug needs no initialization.
  However, the module plug API asks for an `init/1` function.
  """

  @spec init(any) :: false

  def init([]), do: false

  # Private Functions

  @spec edit_body(st) :: st
    when st: String.t

  defp edit_body(body_inp) do
  #
  # Check the body of the output page for a "<toc />" element.
  # If this is present, edit the body:
  #
  # - Wrap header elements in "<a name=...> elements.
  # - Replace the "<toc />" element with a table of contents. 
  #
  #!K - Parsing (etc) HTML with regexen is brittle.

    #!K - This will break if Unicode is present!
    body_tmp  = IO.iodata_to_binary(body_inp)

    patt_toc  = "<toc />"

    if String.contains?(body_tmp, patt_toc) do
#     patt_hdr    = ~r{<[Hh][1-6].+?[Hh][1-6]>}
      patt_hdr    = ~r{<[Hh][3-6].+?[Hh][3-6]>}

      match_list  = patt_hdr
      |> Regex.scan(body_tmp)     # [ [ "<h1>Foo</h1>" ], ... ]
      |> Enum.map(&hd/1)          # [ "<h1>Foo</h1>", ... ]
      |> Enum.with_index()        # [ { "<h1>Foo</h1>", 0 }, ... ]

      match_map   = match_list
      |> Enum.into(%{})           # %{ "<h1>Foo</h1>" => 0, ... }

      replace_fn  = fn header ->
        hdr_ndx   = match_map[header]

        "<a name='#{ get_name(hdr_ndx) }'>#{ header }</a>"
      end

      body_tmp
      |> String.replace(patt_hdr, replace_fn)
      |> String.replace(patt_toc, get_toc(match_list))
    else
      body_inp
    end
  end

  # Private Functions

  defp get_level(header) do
  #
  # Generate a level from a header.

    header                    # "<h3>Foo</h3>"
    |> String.slice(2..2)     # "3"
    |> String.to_integer()    # 3
  end

  defp get_name(ndx), do: "f_#{ ndx }"
  #
  # Generate a name from an index value.

  defp get_toc(match_list) do
  #
  # Generate TOC HTML from the match_list.

    level_base  = 2

    m_r_fn  = fn tup_inp, level_prev ->
      {header, _hdr_ndx}  = tup_inp

      tup_out   = tup_inp                   # { "<h3>Foo</h3>", 2}
      |> Tuple.append(level_prev)           # { "<h3>Foo</h3>", 2, 2}

      level_this  = get_level(header)

      {tup_out, level_this}                 # { { "<h3>Foo</h3>", 2, 2}, 3}
    end

    map_fn  = fn match_tuple ->
      {header, hdr_ndx, level_prev} = match_tuple
      level_this        = get_level(header)

      {:ok, tree}   = Floki.parse_fragment(header)
      hdr_text  = tree  # [{"h1", [], [" ", {"a", [{"href", "/"}], ["Foo"]}]}]
      |> Floki.text()   # " Foo"
      |> String.trim()  # "Foo"

      href        = "'##{ get_name(hdr_ndx) }'"
      item        = String.duplicate("  ",  level_this) <>
                    "<li><a href=#{ href }>#{ hdr_text }</a></li>"
      level_diff  = level_this - level_prev

      cond do
        level_this == level_base ->         # Close out all ul levels.
          adjust  = String.duplicate("</ul>", -level_diff)
          [ adjust ]

        level_diff > 0 ->                   # Increase the ul level.
          adjust  = String.duplicate("<ul>",   level_diff)
          [ adjust, item ]

        level_diff < 0 ->                   # Decrease the ul level.
          adjust  = String.duplicate("</ul>", -level_diff)
          [ adjust, item ]

        true -> item
      end
    end

    dummy_item  = {"<h#{ level_base }></h#{ level_base }>", 99}

    {toc_tmp1, _acc}  = match_list          # [ ..., {"<h4>...</h4>", 20} ]
    |> List.insert_at(-1, dummy_item)       # append {"...", 99}
    |> Enum.map_reduce(level_base, m_r_fn)  # { [ ..., {"...", 99, 4} ], 0}

    toc_tmp2   = toc_tmp1                   # [ ..., {"...", 99, 4} ]
    |> Enum.map(map_fn)                     # [ ..., [ "</ul></ul>" ] ]
    |> List.flatten()                       # [ ..., "</ul></ul>" ]
    |> Enum.join("\n")                      # "...\n</ul></ul>"
    
    """
    <b>Contents:</b>
    <span class="hs-hide1 hs-ih hs-none">(<a
      href="#">hide</a>)</span>
    <span class="hs-show1 hs-is hs-none">(<a
      href="#">show</a>)</span>

    <div class="hs-body1 hs-ih tocx">
    #{ toc_tmp2 }
    </div>
    """
  end
    
end
