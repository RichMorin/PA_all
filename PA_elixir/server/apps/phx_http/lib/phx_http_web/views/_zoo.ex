# phx_http_web/views/_zoo.ex

defmodule PhxHttpWeb.View.Zoo do
#
# Public functions
#
#   fmt_key/1
#     Format the map key (handle special cases, then capitalize the rest).
#   prep_map/1
#     Preprocess the input map.
#
# Private Functions
#
#   prep_map_h/2
#     Preprocess an input string.

  @moduledoc """
  This module provides miscellaneous functions for Views.
  """

# use Phoenix.HTML
# use PhxHttpWeb, :view

  import Common.Tracing, only: [ii: 2], warn: false
  import Common, only: [csv_split: 1, ssw: 2]
  import InfoToml, only: [exp_prefix: 1]

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  Format the map key (handle special cases, then capitalize the rest).

      iex> fmt_key(:faq)
      "FAQ"
      iex> fmt_key(:foo)
      "Foo"
  """

  @spec fmt_key(atom) :: String.t

  def fmt_key(:emacswiki),     do: "EmacsWiki"
  def fmt_key(:faq),           do: "FAQ"
  def fmt_key(:github),        do: "GitHub"
  def fmt_key(:gitlab),        do: "GitLab"
  def fmt_key(:google_p),      do: "Google+"
  def fmt_key(:irc),           do: "IRC"
  def fmt_key(:linked_in),     do: "LinkedIn"
  def fmt_key(:man_page),      do: "Manual Page"
  def fmt_key(:rubydoc),       do: "RubyDoc"
  def fmt_key(:rubygems),      do: "RubyGems"
  def fmt_key(:see_also),      do: "See Also"
  def fmt_key(:sourceforge),   do: "SourceForge"
  def fmt_key(:tty),           do: "TTY"
  def fmt_key(:web_site),      do: "Web Site"
  def fmt_key(:wordpress),     do: "WordPress"
  def fmt_key(:youtube),       do: "YouTube"
  def fmt_key(hdr_atom) do
    hdr_atom                    # :foo
    |> Atom.to_string()         # "foo"
    |> String.capitalize()      # "Foo"
  end

  @doc """
  Preprocess the input map:

  - expand global prefixes (e.g., `"ext_wp|"`)
  - do one level of symbol substitution (e.g., `"main|..."`)
  - remove entries with anonymous keys (e.g., `"_1"`).
  """

  @spec prep_map(PHT.addr_part) :: PHT.addr_part

  def prep_map(inp_map) do

    prep_fn     = fn field -> prep_map_h(field, inp_map) end
    #
    # Return the preprocessed field.

    reduce_fn   = fn {key, inp_val}, acc ->
    #
    # Build a map of preprocessed fields.

      out_val  = inp_val
      |> csv_split()
      |> Enum.map(prep_fn)
      |> Enum.join(", ")

      Map.put(acc, key, out_val)
    end

    ignore_fn   = fn {key, _val} -> "#{ key }" |> ssw("_") end
    #
    # Return true if the (stringified) key starts with an underscore.

    inp_map                         # %{ main: "https:...", ... }
    |> Enum.reject(ignore_fn)       # [ main: "https:...", ... ]
    |> Enum.reduce(%{}, reduce_fn)  # %{ main: "https:...", ... }
  end

  # Private Functions

  @spec prep_map_h(st, PHT.addr_part) :: st
    when st: String.t

  defp prep_map_h(inp_val, inp_map) do
  #
  # Preprocess an input string:
  #   expand global prefixes (eg, "ext_wp|")
  #   do one level of symbol substitution (eg, "main|...")

    exp_val   = exp_prefix(inp_val)

    fields    = exp_val |> String.split("|")

    if Enum.count(fields) == 2 do
      [ pre_str, body] = fields
      pre_atom  = String.to_atom(pre_str)
      prefix    = inp_map[pre_atom]
      "#{ prefix }#{ body }"
    else
      exp_val
    end
  end

end
