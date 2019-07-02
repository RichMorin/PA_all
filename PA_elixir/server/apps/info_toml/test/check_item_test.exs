# info_toml/test/check_item_test.exs

defmodule InfoTomlTest.CheckItem do

  use ExUnit.Case

  import ExUnit.CaptureIO
  import InfoToml.Common

  alias InfoToml.{CheckItem, Schemer}

  setup_all do
    tree_abs    = get_tree_abs()
    schemas     = Schemer.get_schemas(tree_abs)

    min_map     = %{
      about:  %{
        precis:     "precis",
        verbose:    "verbose"
      },
      
      meta: %{
        actions:    "actions",
        id_str:     "id_str",
        refs: %{ }
      }
    }

    { :ok,
      min_map:  min_map,
      schemas:  schemas
    }
  end

  test "rejects item with a bogus key", state do
    file_key    = "Foo/Bar/main.toml"
    schemas     = state.schemas

    inp_map     = state.min_map
    |> put_in([ :foo ], "bar")

    fun = fn -> refute CheckItem.check(inp_map, file_key, schemas) end
    capture_io(fun)
  end

  test "rejects item with a bogus value (1)", state do
    file_key    = "Foo/Bar/main.toml"
    schemas     = state.schemas

    inp_map     = state.min_map
    |> put_in([ :meta, :actions ], "  ")

    fun = fn -> refute CheckItem.check(inp_map, file_key, schemas) end
    capture_io(fun)
  end

  test "rejects item with a bogus value (2)", state do
    file_key    = "Foo/Bar/main.toml"
    schemas     = state.schemas

    inp_map     = state.min_map
    |> put_in([ :meta, :actions ], "say what???")

    fun = fn -> refute CheckItem.check(inp_map, file_key, schemas) end
    capture_io(fun)
  end

  test "rejects item with no 'publish' action", state do
    file_key    = "Foo/Bar/main.toml"
    inp_map     = state.min_map
    schemas     = state.schemas

    fun = fn -> refute CheckItem.check(inp_map, file_key, schemas) end
    capture_io(fun)
  end

  test "accepts item with a 'publish' action", state do
    file_key    = "Foo/Bar/main.toml"
    schemas     = state.schemas

    inp_map     = state.min_map
    |> put_in([ :meta, :actions ], "foo,publish,bar")

    assert CheckItem.check(inp_map, file_key, schemas)
  end

end
