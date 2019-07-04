# phx_http_web/views/search_view.ex

defmodule PhxHttpWeb.SearchView do
#
# Public functions
#
#   result_header/1
#     Generate header text for a result set.
#   result_url/1
#     Generate the URL text for a result.

  @moduledoc """
  This module supports rendering of the `search` templates.
  """

  use Phoenix.HTML
  use PhxHttpWeb, :view

  import Common #D
  import PhxHttpWeb.View.Tag

  @doc """
  Get a map of tag values for the specified type.
  If the type is `:_`, return a merged map for all tag values.

      iex> kv_map = %{ t1: %{ a: 1, b: 2 }, t2: %{ b: 10, c: 3 } }
      iex> get_sub_map(kv_map, :_)
      %{a: 1, b: 12, c: 3}
      iex> get_sub_map(kv_map, :t1)
      %{a: 1, b: 2}
  """

  @spec get_sub_map(map, s) :: map when s: String.t #W

  def get_sub_map(kv_map, :_) do

    sum_fn      = fn _tag, cnt_1, cnt_2 -> cnt_1 + cnt_2 end
    #
    # Sum a pair of tag usage counts, ignoring type.

    tally_fn    = fn {_type, sub_map}, acc ->
    #
    # Sum the usage counts for this tag, across all types.

      Map.merge(acc, sub_map, sum_fn)
    end

    kv_map                          # %{ t1: %{a: 1, b: 2}, t2: %{b: 10, c: 3} }
    |> Enum.reduce(%{}, tally_fn)   # %{ a: 1, b: 12, c: 3 }
  end

  def get_sub_map(kv_map, tag_type), do: kv_map[tag_type]

  @doc """
  Generate header text for a result set.

      iex> path     = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> results  = [ { path, "...", "..." } ]
      iex> result_header(results)
      {"Areas/Catalog", 1}
  """

  @spec result_header( [ {s, s, s} ] ) :: {s, integer} when s: String.t #W

  def result_header(results) do

    {path, _title, _precis} = List.first(results)

    base_patt   = ~r{ ^ ( \w+ / \w+ ) / .* $ }x
    header      = String.replace(path, base_patt, "\\1")
    count       = Enum.count(results)

    {header, count}
  end

  @doc """
  Generate the URL text for a result.

      iex> item_key   = "Areas/Catalog/People/Rich_Morin/main.toml"
      iex> result_url(item_key)
      "/item?key=Areas/Catalog/People/Rich_Morin/main.toml"
  """

  @spec result_url(s) :: s when s: String.t #W

  def result_url(key), do: "/item?key=#{ key }"

end
