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
  Wrap `IO.inspect/2`, making it less painful to use:
  
  - shorten the name from ten to two characters
  - reduce ceremony by eliminating the `:label` key
  - make floats print with only two decimal places
  """

  @spec ii(any, atom | String.t) :: any

  def ii(float, label) when is_float(float) do
    float
    |> :erlang.float_to_binary(decimals: 2)
    |> ii(label)
  end

  def ii(thing, label), do: IO.inspect(thing, label: label)

  @doc """
  Print a labeled time stamp, e.g.:
  
      lts>> 22.837 - PhxHttpWeb.TextController.show/2

  The full ISO 8601 time stamp (e.g., `2019-05-08T14:09:22.837127Z`)
  is unambiguous, but also long and complicated.  So, it's difficult
  to digest in a single glance.  Printing just the seconds and milliseconds
  (e.g., `22.837`) works much better for informal timing analysis.
  """

  @spec lts(String.t) :: any

  def lts(label) do
    iso8601   = DateTime.utc_now()
    |> DateTime.to_iso8601()            # 2019-05-08T14:09:22.837127Z

    pattern   = ~r< ^ [^:]+ : \d\d : (.{6}) .* $ >x
    trimmed   = iso8601
    |> String.replace(pattern, "\\1")   # 22.837

    IO.puts "lts>> #{ trimmed } - #{ label }"
  end

end
