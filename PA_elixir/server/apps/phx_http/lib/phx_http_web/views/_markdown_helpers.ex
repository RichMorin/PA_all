# phx_http_web/views/_markdown_helpers.ex

defmodule PhxHttpWeb.MarkdownHelpers do
#
# Public functions
#
#   fmt_markdown/2
#     Convert Markdown to HTML.
#
# Private functions
#
#   fmt_markdown_h/3
#     Format error text for fmt_markdown/2.

  @moduledoc """
  Conveniences for formatting Markdown content.
  """

  use Phoenix.HTML

  alias PhxHttp.Types, as: PT
  alias PhxHttpWeb.LinkHelpers

  # Public functions

  @doc """
  This function converts Markdown to HTML.  In the process, it expands some
  prefix strings.
  """

  @spec fmt_markdown(map, [atom]) :: PT.safe_html #W

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