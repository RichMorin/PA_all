# common/sorting.ex

defmodule Common.Sorting do
#
# Public functions
#
#   sort_by_elem/2
#     Sort a list by an indexed element.
#   sort_by_elem/3
#     Sort a list by an indexed element, in a specified mode.

  @moduledoc """
  This module provides convenience functions for sorting.
  """

  # Public functions

  @spec sort_by_elem([], non_neg_integer) :: []

  @doc """
  Sort a list by an indexed element.

      iex> list = [ {2, 30}, {1, 10}, {3, 20} ]
      iex> sort_by_elem(list, 0)
      [ {1, 10}, {2, 30}, {3, 20} ]
      iex> sort_by_elem(list, 1)
      [ {1, 10}, {3, 20}, {2, 30} ]
  """

  def sort_by_elem(list, index), do: sort_by_elem(list, index, nil)

  @doc """
  Sort a list by an indexed element, in a specified mode.
  Currently, the only supported mode is `:dc`,
  which sorts in a case-insensitive (i.e., downcased) manner.

      iex> list = [ {:def, 30}, {:Abc, 10}, {:Ghi, 20} ]
      iex> sort_by_elem(list, 0, :dc)
      [ {:Abc, 10}, {:def, 30}, {:Ghi, 20} ]
      iex> sort_by_elem(list, 0, nil)
      [ {:Abc, 10}, {:Ghi, 20}, {:def, 30} ]
  """

  def sort_by_elem(list, index, mode) do

    sort_fn   = fn item ->
    #
    # Support normal and (stringified) downcased sorting.

      case mode do
        :dc ->
          "#{ elem(item, index) }" |> String.downcase()

        _ ->
          elem(item, index)
      end
    end

    Enum.sort_by(list, sort_fn)
  end

end
