# common_test.exs

defmodule CommonTest do

  use ExUnit.Case

  import Common

# doctest Common
  doctest Common.Maps
# doctest Common.Server
  doctest Common.Sorting
  doctest Common.Strings
  doctest Common.Tracing
  doctest Common.Zoo
end
