# common/tracing.ex

defmodule Common.Tracing do
#
# Public functions
#
#   ii/2
#     Wrap IO.inspect/2, making it less painful to use.
#   lts/1
#     Print a labeled time stamp.

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

  @doc """
  Print a labeled time stamp, eg:
  
      lts>> PhxHttpWeb.TextController.show/2 @ 40.97
  """

  @spec lts(String.t) :: any

  def lts(label) do
    iso8601   = DateTime.utc_now()
    |> DateTime.to_iso8601()            # 2019-05-08T14:09:22.837127Z

    pattern   = ~r< ^ [^:]+ : \d\d : (.{5}) .* $ >x
    trimmed   = iso8601
    |> String.replace(pattern, "\\1")   # 22.837

#   IO.puts "lts>> #{ label } @ #{ trimmed } (#{ iso8601 })"
#   IO.puts "lts>> #{ label } @ #{ trimmed }"
    IO.puts "lts>> #{ trimmed } - #{ label }"
  end

end
