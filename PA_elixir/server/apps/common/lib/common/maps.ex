# common/maps.ex

defmodule Common.Maps do
#
# Public functions
#
#   get_map_max/1
#     Get the maximum value of a map.
#   keyss/1
#     Get the keys to a map and return them in sorted order.

  @moduledoc """
  This module contains map-handling functions for common use.
  """

  import Common, warn: false, only: [ii: 2]

  alias Common.Types, as: CT

  # Public functions

  @doc """
  Get the maximum value of a non-empty map.

      iex> m = %{ a: 1, b: 2, c: 3 }
      iex> get_map_max(m)
      3
  """

  @spec get_map_max( %{required(CT.map_key) => any} ) :: any
  # The map value can be anything that we can stringify.

  def get_map_max(inp_map), do: inp_map |> Map.values |> Enum.max()

  @doc """
  Return the (stringified) keys to a map in a sorted order.
  The keys are sorted alphanumerically by the downcased string interpretation.
  
      iex> m = %{ "C" => 3, b: 2, a: 1 }
      %{ "C" => 3, a: 1, b: 2 }
      iex> keyss(m)
      [ :a, :b, "C" ]

  This function is useful when displaying things (e.g., traces, web pages),
  because it causes them to fall into a predictable order.
  And, because one never knows when something will need to be traced, we
  use the function as a standard practice.
  """

  @spec keyss( %{ CT.map_key => any } ) :: [String.t]
  # The map value could be anything; we don't care.

  def keyss(map) do

    sort_fn   = fn key -> "#{ key }" |> String.downcase() end
    #
    # Support a case-insensitive sort on stringified keys.
 
    map                           # %{ "C" => 3, b: 2, a: 1 }
    |> Map.keys()                 # [ "C", :b, :a ]
    |> Enum.sort_by(sort_fn)      # [ :a, :b, "C" ]
  end

end
