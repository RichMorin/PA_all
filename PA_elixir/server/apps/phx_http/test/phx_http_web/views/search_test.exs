# search_test.exs

defmodule PhxHttpWeb.SearchViewTest do

  use ExUnit.Case
  use PhxHttpWeb.ConnCase, async: true

  import  Common
  import  PhxHttpWeb.SearchView

  doctest PhxHttpWeb.SearchView
end
