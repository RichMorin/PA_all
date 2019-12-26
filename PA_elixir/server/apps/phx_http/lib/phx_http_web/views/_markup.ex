# phx_http_web/views/_markup.ex

defmodule PhxHttpWeb.View.Markup do
#
# Public functions
#
#   fmt_markup/1
#     Convert a string containing markup (extended Markdown) to HTML.
#   fmt_section/2
#     Convert a section containing markup (extended Markdown) to HTML.
#
# Private functions
#
#   markup_err/3
#     Format error text for fmt_markup/1.
#   section_err/3
#     Format error text for fmt_section/2.

  @moduledoc """
  Conveniences for formatting markup (extended Markdown) content.
  """

  use Phoenix.HTML

  import Common, warn: false, only: [ ii: 2 ]
  import PhxHttpWeb.View.Link, only: [do_links: 1 ]

  alias InfoToml.Types, as: ITT
  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  This function converts a string containing markup (extended Markdown)
  to HTML.  In the process, it expands some prefix strings.
  """

  @spec fmt_markup(st) :: st
    when st: String.t

  def fmt_markup(md_inp) do
    md_exp    = do_links(md_inp)
    pattern   = ~r{^<p>(.+)</p>\s$}

    case Earmark.as_html(md_exp) do
      {:ok, html, []} ->
        html |> String.replace(pattern, "\\1")

      {_, _input, err_list} ->
        markup_err(md_inp, err_list)

#     unknown -> "<p>#{ inspect(unknown) }</p>"   #!D
    end
  end

  @doc """
  This function extracts a section containing markup (extended Markdown)
  and converts it to HTML.  In the process, it handles file inclusions
  and expands some prefix strings.
  """

  @spec fmt_section(ITT.item_map, [atom]) :: PHT.safe_html

  def fmt_section(inp_map, gi_list) do
    md_exp  = inp_map
    |> get_in(gi_list)
    |> do_links()

    case Earmark.as_html(md_exp) do
      {:ok, html, []} -> html

      {_, _input, err_list} ->
        section_err(inp_map, gi_list, err_list)

#     unknown -> "<p>#{ inspect(unknown) }</p>"   #!D
    end |> raw()
  end

  # Private Functions

  @spec markup_err(st, iodata) :: st
    when st: String.t

  defp markup_err(inp_str, message) do
  #
  # Format an error message from this tuple. 

    """
      <p>
        <b>Earmark:</b>
        <pre>
    diagnostic:   "#{ message }"
    input string: "#{ inp_str }"</pre>
      </p>
    """
  end

  @spec section_err(ITT.item_map, [atom], PHT.err_list) :: String.t

  defp section_err(inp_map, gi_list, err_list) do
  #
  # Format error text for fmt_section/2.

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

      pattern     = ~r{^Closing unclosed backquotes}
      line_info   = if message =~ pattern do
        ""
      else
        """
        line number:  #{ ndx_rare }
        line text:    "#{ line_text }"
        """
      end

      """
        <p>
          <b>Earmark #{ type }:</b>
          <pre>
      diagnostic:   "#{ message }"
      get_in list:  #{ inspect(gi_list) }
      #{ line_info }</pre>
        </p>
      """
    end

    err_list             # [ {:warning, 1, "..."}, ... ]
    |> Enum.map(fmt_fn)  # [ "<p>...</p>", ... ]
    |> Enum.join("\n")   # "<p>...</p>\n..."
  end

end