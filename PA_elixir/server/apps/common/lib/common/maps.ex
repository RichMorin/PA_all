defmodule Common.Maps do
#
# Public functions
#
#   keyss/1
#     Get the keys to a Map and return them in sorted order.
#   our_tree/[12]
#     Check whether this is (our style of) a tree of Maps.
#
# Private functions
#
#   our_tree_h/1
#     Crawl the Map tree for our_tree/2.

  import Common.Tracing

  @moduledoc """
  This module contains Map-handling functions for common use.
  """

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
  Check whether this is (our style of) a tree of Maps.  Specifically,
  the keys should all be Atoms or Strings and the values should either
  be compliant Maps or something else.  If `strict` is true, something
  else should be Booleans, Numbers, or Strings
  
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

# @spec - WIP

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
