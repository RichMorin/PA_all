# info_toml/trees.ex

defmodule InfoToml.Trees do
#
#   leaf_paths/[13]
#     Get a list of access paths for the leaf nodes of a tree of maps.
#   our_tree/[12]
#     Check whether this is (our style of) a tree of maps.
#
# Private functions
#
#   leaf_paths_h/2
#     Recursive helpers for leaf_paths/3
#   our_tree_h/1
#     Crawl the map tree for our_tree/2.

  @moduledoc """
  This module contains functions to support tree handling.
  """

  alias Common.Types, as: CT
  alias InfoToml.Types, as: ITT

  @doc """
  Get a list of data structure access paths, as used in `get_in/2`,
  for the leaf nodes of a tree of maps.

      iex> m1 = %{ a: %{ b: 1, c: 2 } }
      iex> leaf_paths(m1)
      [[:a, :c], [:a, :b]]
      iex> m2 = %{ d: %{ e: %{ f: 42 } } }
      iex> leaf_paths(m2)
      [[:d, :e, :f]]
      iex> m3 = %{ "f" => %{ m1: m1, m2: m2 } }
      iex> leaf_paths(m3)
      [["f", :m2, :d, :e, :f], ["f", :m1, :a, :c], ["f", :m1, :a, :b]]
  """
  
  # The code below was adapted from a reply by Peer Reynders (peerreynders)
  # to a help request on the Elixir Forum: `https://elixirforum.com/t/17715`.

  @spec leaf_paths(ITT.item_map) :: [ [CT.map_key] ]

  def leaf_paths(tree), do: leaf_paths(tree, [], [])

  @spec leaf_paths(ITT.item_map, ll, ll) :: ll
    when ll: [ [CT.map_key, ...] ]

  defp leaf_paths(tree, parent_path, paths) do
    {_, paths} = Enum.reduce(tree, {parent_path, paths}, &leaf_paths_h/2)
    paths
  end

  @doc """
  Check whether this is (our style of) a tree of maps.  Specifically,
  the keys should all be atoms or strings and the values should either
  be compliant maps or something else.  If `strict` is true, "something
  else" must be a boolean, number, or string.
  
      iex> nil    |> our_tree()
      false
      iex> 42     |> our_tree()
      false
      iex> :foo   |> our_tree()
      false
      iex> "foo"  |> our_tree()
      false

      iex> %{}                            |> our_tree()
      false
      iex> %{ foo: true }                 |> our_tree()
      true
      iex> %{ foo: 42 }                   |> our_tree()
      true
      iex> %{ foo: :bar }                 |> our_tree()
      false
      iex> %{ foo: "bar" }                |> our_tree()
      true
      iex> %{ "foo" => "bar" }            |> our_tree()
      true
      iex> %{ "foo" => %{ bar: "baz" } }  |> our_tree()
      true

  This function is useful for testing data structures.
  """

  @spec our_tree(any) :: bool
  #!V - any (indeed, could be anything...)

  def our_tree(input), do: our_tree(input, true)

  @doc """
  Like `our_tree/1`, but allows non-strict checking.
  """

  @spec our_tree(any, bool) :: bool
  #!V - any (indeed, could be anything...)

  def our_tree(input, strict) do
    if is_map(input) do
#     ii(input, :input1)
      our_tree_h(input, strict)
    else
      false
    end
  end

  # Private functions

  @spec leaf_paths_h({atom, part}, {path, [path]} ) :: {String.t, [part]}
    when part: ITT.item_part, path: ITT.item_path

  defp leaf_paths_h({key, value}, {parent_path, paths}) when is_map(value), do:
    {parent_path, leaf_paths(value, [ key | parent_path ], paths) }

  defp leaf_paths_h({key, _value}, {parent_path, paths}), do:
    {parent_path, [ :lists.reverse( [ key | parent_path ] ) | paths ] }

  @spec our_tree_h(map, bool) :: bool

  defp our_tree_h(input, strict) when is_map(input) do

    acc_chk_fn  = fn {key, value}, acc ->
    #
    # Accumulate checks for the tree.  (Return false if any check fails.)

      cond do
        is_atom(key)    -> acc && !!our_tree_h(value, strict) #!R
        is_binary(key)  -> acc && !!our_tree_h(value, strict) #!R
        true            -> false
      end
    end

    if Enum.empty?(input) do
      false
    else
      Enum.reduce(input, true, acc_chk_fn)
    end
  end

  defp our_tree_h(input, true) do
    cond do
      is_binary(input)    -> true
      is_boolean(input)   -> true
      is_number(input)    -> true
      true                -> false
    end
  end

  defp our_tree_h(_input, _strict), do: true

end
