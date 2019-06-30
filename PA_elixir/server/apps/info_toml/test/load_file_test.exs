# info_toml/test/load_file_test.exs

defmodule InfoTomlTest.LoadFile do

  use ExUnit.Case

  import Common, only: [ our_tree: 2 ]

  alias InfoToml.{Common, LoadFile, Schemer}

  @moduledoc """
  The `load/1` function in `InfoToml.LoadTree` isn't well suited for testing,
  so we drop down a couple of levels and do a sanity check on `do_file/3`.
  Thus, the `do_tree/2` function (which handes the file tree walk) is not
  tested.  However, testing at this level tends to validate parsing, etc. 
  """

  setup_all do
    id_num      = 42
    tree_abs    = Common.get_tree_abs()
    schemas     = Schemer.get_schemas(tree_abs)

    result      = "_schemas/main.toml" 
    |> LoadFile.do_file(id_num, schemas)

    { _key, schema } = result

    { :ok,
      schema:   schema
    }
  end

  test "returns right shape of data for _schemas/main.toml", state do
    schema  = state.schema

    assert  our_tree(schema, true)

    assert  is_map schema.about
    assert  is_map schema.address
    assert  is_map schema.address.document
    assert  is_map schema.address.email
    assert  is_map schema.address.phone
    assert  is_map schema.address.postal
    assert  is_map schema.address.related
    assert  is_map schema.address.web_site
    assert  is_map schema.meta
    assert  is_map schema.meta.refs
    assert  is_map schema.meta.tags
  end

end
