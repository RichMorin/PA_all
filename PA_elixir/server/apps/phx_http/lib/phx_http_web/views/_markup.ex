# phx_http_web/views/_markup.ex

defmodule PhxHttpWeb.View.Markup do
#
# Public functions
#
#   fmt_markup/2
#     Convert markup (extended Markdown) to HTML.
#
# Private functions
#
#   fmt_markup_h/3
#     Format error text for fmt_markup/2.

  @moduledoc """
  Conveniences for formatting markup (extended Markdown) content.
  """

  use Phoenix.HTML

  import PhxHttpWeb.View.Link, only: [do_links: 1 ]

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  This function converts markup (extended Markdown) to HTML.  In the process,
  it expands some prefix strings.
  """

  @spec fmt_markup(map, [atom]) :: PHT.safe_html #W - map

  def fmt_markup(inp_map, gi_list) do
    md_inp  = get_in(inp_map, gi_list)
    md_exp  = do_links(md_inp)

    case Earmark.as_html(md_exp) do
      {:ok, html, []} -> html

      {:error, _input, err_list} ->
        fmt_markup_h(inp_map, gi_list, err_list)

#     unknown -> "<p>#{ inspect(unknown) }</p>"   #D
    end |> raw()
  end

  # Private Functions

  @spec fmt_markup_h(map, [atom], list) :: String.t #W - list, map

  defp fmt_markup_h(inp_map, gi_list, err_list) do
  #
  # Format error text for fmt_markup/2.

    last_key  = List.last(gi_list)
    off_key   = "o_#{ last_key }" |> String.to_atom()

    off_int   = inp_map
    |> get_in([:meta, off_key])
    |> String.to_integer()
    
    fmt_fn  = fn {type, ndx_raw, message} ->
    #
    # Format an error message from this tuple. 

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