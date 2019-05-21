# common/maps.ex

defmodule Common.Maps do
#
# Public functions
#
#   get_map_max/1
#     Get the maximum value of a map.
#   keyss/1
#     Get the keys to a Map and return them in sorted order.
#   leaf_paths/[13]
#     Get a list of access paths for the leaf nodes of a tree of maps.
#   our_tree/[12]
#     Check whether this is (our style of) a tree of Maps.
#
# Private functions
#
#   leaf_paths_h/2
#     Recursive helpers for leaf_paths/3
#   our_tree_h/1
#     Crawl the Map tree for our_tree/2.

  @moduledoc """
  This module contains Map-handling functions for common use.
  """

  use Common.Types

  import Common, warn: false, only: [ii: 2]

  # Public functions

  @doc """
  Get the maximum value of a map.
  """
  @spec get_map_max( %{String.t => i} ) :: i when i: integer

  def get_map_max(inp_map) do

    reduce_fn   = fn ({_key, val}, acc) -> max(val, acc) end

    inp_map |> Enum.reduce(0, reduce_fn)
  end

  @doc """
  Return the keys to a Map and return them in sorted order.
  The keys are sorted by the downcased String interpretation.
  
      iex> m = %{ C: 3, b: 2, a: 1 }
      %{ C: 3, a: 1, b: 2 }
      iex> keyss(m)
      [ :a, :b, :C ]

  This function is useful when displaying things (e.g., traces, web pages).
  And, because one never knows when something will need to be traced, we
  use the function as a standard practice.
  """

  @spec keyss(map) :: list

  def keyss(map) do
    sort_fn   = fn inp -> "#{ inp }" |> String.downcase() end
 
    map                           # %{ C: 3, b: 2, a: 1 }
    |> Map.keys()                 # [ :C, :b, :a ]
    |> Enum.sort_by(sort_fn)      # [ :a, :b, :C ]
  end

  @doc """
  Get a list of data structure access paths, as used in `get_in/2`,
  for the leaf nodes of a tree of maps.
  """
  
  # The code below was adapted from a reply by Peer Reynders (peerreynders)
  # to a help request on the Elixir Forum: `https://elixirforum.com/t/17715`.

  @spec leaf_paths(item_map) :: [ [ atom | String.t ] ]

  def leaf_paths(tree), do: leaf_paths(tree, [], [])

  @spec leaf_paths(item_map, l, l) :: l when l: [ [ atom | String.t ] ]

  def leaf_paths(tree, parent_path, paths) do
    {_, paths} = Enum.reduce(tree, {parent_path, paths}, &leaf_paths_h/2)
    paths
  end

  @doc """
  Check whether this is (our style of) a tree of Maps.  Specifically,
  the keys should all be Atoms or Strings and the values should either
  be compliant Maps or something else.  If `strict` is true, "something
  else" must be a Boolean, Number, or String.
  
      iex> our_tree nil
      false
      iex> our_tree 42
      false
      iex> our_tree :foo
      false
      iex> our_tree "foo"
      false

      iex> our_tree %{}
      false
      iex> our_tree %{ foo: true }
      true
      iex> our_tree %{ foo: 42 }
      true
      iex> our_tree %{ foo: :bar }
      false
      iex> our_tree %{ foo: "bar" }
      true
      iex> our_tree %{ "foo" => "bar" }
      true
      iex> our_tree %{ "foo" => %{ bar: "baz" } }
      true

  This function is useful for testing data structures.
  """

  @spec our_tree(any) :: boolean

  def our_tree(input), do: our_tree(input, true)

  @spec our_tree(any, b) :: b when b: boolean

  def our_tree(input, strict) do
    if is_map(input) do
#     ii(input, :input1)
      our_tree_h(input, strict)
    else
      false
    end
  end

  # Private functions

  @spec leaf_paths_h({atom, any}, {item_path, item_paths}) ::
    {String.t, [ item_part ] }

  defp leaf_paths_h({key, value}, {parent_path, paths}) when is_map(value), do:
    {parent_path, leaf_paths(value, [ key | parent_path ], paths) }

  defp leaf_paths_h({key, _value}, {parent_path, paths}), do:
    {parent_path, [ :lists.reverse( [ key | parent_path ] ) | paths ] }

  @spec our_tree_h(map, b) :: b when b: boolean

  defp our_tree_h(input, strict) do
    reduce_fn   = fn {key, value}, acc ->
      cond do
        is_atom(key)    -> acc && !!our_tree_h(value, strict)
        is_binary(key)  -> acc && !!our_tree_h(value, strict)
        true            -> false
      end
    end

    cond do
      is_map(input)     ->
        if Enum.empty?(input) do
          false
        else
          Enum.reduce(input, true, reduce_fn)
        end

      strict            ->
        cond do
          is_binary(input)    -> true
          is_boolean(input)   -> true
          is_number(input)    -> true
          true                -> false
        end

      true                    -> true
    end
  end

end
