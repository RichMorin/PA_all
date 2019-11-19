# controllers/item_controller.ex

defmodule PhxHttpWeb.Cont.Items do
#
# Public functions
#
#   get_gi_bases/1
#     Get a sorted, unique list of "base paths" from the `gi_pairs` list.
#   get_gi_pairs/1
#     Get a list of `{gi_path, value}` pairs.
#   get_item_map/2
#     Generate an "item map", based on `gi_bases` and `gi_pairs`.
#   get_make/1
#     Get `make.toml` information for an item.
#   get_reviews/1
#     Get a list of keys for this item's reviews.
#   get_slides/1
#     Get `s_*.toml` information for an item.
#
# Private functions
#
#   get_extras/1
#     Get information for an item's "extras".
#   get_gi_path/1
#     Get a `gi_path`, based on a `dot_path`

  @moduledoc """
  This module provides functions to retrieve information on items.
  """

  import Common, only: [ sort_by_elem: 2 ]

  alias InfoToml.Types, as: ITT
  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  Get a sorted, unique list of "base paths" from the `gi_pairs` list.
  (This is used by `get_item_map/2` to pre-populate interior map nodes.)
  """

  @spec get_gi_bases( [PHT.gi_pair] ) :: [ [atom, ...] ]

  def get_gi_bases(gi_pairs) do

    bases_fn  = fn
    #
    # Return a list of gi_base lists.
    #
    #!K Handles only three levels of maps.

      { [a, _],       _val }  -> [ [a] ]
      { [a, b, _],    _val }  -> [ [a], [a, b] ]
      { [a, b, c, _], _val }  -> [ [a], [a, b], [a, b, c] ]
    end

    gi_pairs                      # [ { [:a, :b, :c], "42" }, ... ]
    |> Enum.map(bases_fn)         # [ [[:a]], [[:a, :b]], ... ]
    |> Enum.concat()              # [ [:a], [:a, :b], ... ]
    |> Enum.sort()                # ditto, but sorted
    |> Enum.uniq()                # ditto, but unique
#   |> ii("gi_bases") #!T
  end

  @doc """
  Get a list of `{gi_path, value}` pairs, where `gi_path`
  is an access path list, as used by `get_in/2`.
  """

  @spec get_gi_pairs(any) :: [PHT.gi_pair]

  def get_gi_pairs(params) do

    prefix      = ~r{ ^ PA \. }x

    filter_fn   = fn {key,  val} -> key =~ prefix && val != "" end
    #
    # Return true for non-empty "PA.*" params.

    tuple_fn    = fn {key, val} ->
    #
    # Return a tuple, composed of a gi_path and an id_str.

      gi_path = key                     # "PA.meta.id_str"
      |> String.replace(prefix, "")     # "meta.id_str"
      |> get_gi_path()                  # [ :meta, :id_str ]

      {gi_path, val}                    # { [ :meta, :id_str ], "Alot" }
    end

    params                        # [ { "PA.meta.id_str", "Alot" }, ... ]
    |> Enum.filter(filter_fn)     # keep only non-empty "PA.*" params
    |> Enum.map(tuple_fn)         # [ { [:meta, :id_str], "Alot" }, ... ]
    |> sort_by_elem(0)            # sort by gi_path, eg: [:meta, :id_str]
#   |> ii("gi_pairs") #!T
  end

  @doc """
  Generate an "item map", based on:

  - `gi_bases` - a list of interior (i.e., base) `gi_path` lists
  - `gi_pairs` - a list of key/value tuples, e.g.: `{gi_path, val}`
  """

  @spec get_item_map([ [atom, ...] ], [PHT.gi_pair]) :: ITT.item_map

  def get_item_map(gi_bases, gi_pairs) do
  #
  # ToDo: Detect and handle wonky (non-UTF8) characters.

    # Create the interior nodes.

    base_fn   = fn gi_list, acc -> put_in(acc, gi_list, %{}) end
    #
    # Create the base map.

    base_map    = gi_bases            # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(%{}, base_fn)      # %{ meta: %{}, ... }
#   |> ii("base_map") #!T

    # Fold in the exterior nodes.

    augment_fn  = fn {gi_list, val}, acc -> put_in(acc, gi_list, val) end
    #
    # Augment the base map with exterior nodes.

    gi_pairs                              # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(base_map, augment_fn)  # %{ meta: %{ id_str: <value> }, ... }
#   |> ii("item_map") #!T
  end

  @doc """
  Get any `make.toml` information for the item.
  """

  @spec get_make(String.t) :: ITT.item_maybe

  def get_make(key) do
  #
  # Get any some `make.toml` information.

    make_key  = key
    |> String.replace_suffix("/main.toml", "/make.toml")

    InfoToml.get_item(make_key)
  end

  @doc """
  Get a list of keys for this item's reviews.
  """

  @spec get_reviews(st) :: [st] when st: String.t

  def get_reviews(key) do

    pattern   = ~r{ / text \. \w+ \. toml $ }x
    get_extras(key, pattern)
  end

  @doc """
  Get a list of keys for this item's slides.
  """

  @spec get_slides(st) :: [st] when st: String.t

  def get_slides(key) do
    pattern   = ~r{ / s_\w+ \. toml $ }x
    get_extras(key, pattern)
  end

  # Private Functions

  @spec get_extras(st, Regex.t) :: [st] when st: String.t

  def get_extras(key, pattern) do
  #
  # Get a list of keys for some of this item's extra files.

    extra_fn   = fn {path, _title, _precis} ->
    #
    # Return true for extra items.

      String.match?(path, pattern)
    end

    key
    |> String.replace(~r{[^/]+$}, "")
    |> InfoToml.get_item_tuples()
    |> Enum.filter(extra_fn)
    |> sort_by_elem(0)
    |> Enum.map(fn x -> elem(x, 0) end)
  end

  @spec get_gi_path(String.t) :: [atom, ...]

  defp get_gi_path(dot_path) do
  #
  # Get a `gi_path` (an access path list, as used by `get_in/2`),
  # based on a `dot_path` (a dot-separated list of names), eg:
  #
  #   "foo.bar.baz" -> `[:foo, :bar, :baz]`.

    dot_path                          # "foo.bar.baz"
    |> String.split(".")              # [ "foo", "bar", "baz" ]
    |> Enum.map(&String.to_atom/1)    # [ :foo, :bar, :baz ]
#   |> ii("gi_path") #!T
  end

end
