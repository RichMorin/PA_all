# _helper_test.exs

defmodule PhxHttpWeb.HelperTest do

  use ExUnit.Case

  import  Common
  import  PhxHttpWeb.HideHelpers
  import  PhxHttpWeb.TagHelpers

  doctest PhxHttpWeb.HideHelpers
  doctest PhxHttpWeb.TagHelpers
end
