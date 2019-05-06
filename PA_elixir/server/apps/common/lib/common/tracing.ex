# common/tracing.ex

defmodule Common.Tracing do
#
# Public functions
#
#   ii/2
#     Wrap IO.inspect/2, making it less painful to use.

  @moduledoc """
  This module contains tracing functions for common use.
  """

  # Public functions

  @doc """
  Wrap `IO.inspect/2`, making it less painful to use.  Specifically:
  
  - shorten the name from ten to two characters
  - reduce ceremony by eliminating the `:label` key
  - make floats print with only two decimal places
  """

  @spec ii(any, atom | String.t) :: any

  def ii(float, label) when is_float(float) do
    float_str   = :erlang.float_to_binary(float, [decimals: 2])
    ii(float_str, label)
  end

  def ii(thing, label), do: IO.inspect(thing, label: label)

end
