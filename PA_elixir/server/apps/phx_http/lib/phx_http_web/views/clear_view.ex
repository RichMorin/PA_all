# phx_http_web/views/clear_view.ex

defmodule PhxHttpWeb.ClearView do
#
# Public functions
#
#   result_header/1
#     Generate header text for a result set.
#   result_url/1
#     Generate the URL text for a result.

  @moduledoc """
  This module supports rendering of the `clear` templates.
  """

  use Phoenix.HTML
  use PhxHttpWeb, :view

  import PhxHttpWeb.View.Tag

  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  Return header information for a result set.

      iex> path     = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> results  = [ { path, "...", "..." } ]
      iex> result_header(results)
      {"Areas/Catalog", 1}
  """

  @spec result_header( [ITT.item_tuple] ) :: {String.t, integer}

  def result_header(results) do
    {path, _title, _precis} = List.first(results)
    hdr_count   = Enum.count(results)

    base_patt   = ~r{ ^ ( \w+ / \w+ ) / .* $ }x
    hdr_text    =  String.replace(path, base_patt, "\\1")

    {hdr_text, hdr_count}
  end

  @doc """
  Generate the URL text for a result.

      iex> item_key   = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> result_url(item_key)
      "/item?key=Areas/Catalog/People/Rich_Morin/main.toml"
  """

  @spec result_url(st) :: st
    when st: String.t

  def result_url(key), do: "/item?key=#{ key }"

end
