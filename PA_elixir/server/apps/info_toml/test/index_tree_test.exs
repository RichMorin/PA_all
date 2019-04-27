# index_tree_test.exs

defmodule InfoTomlTest.IndexTree do

  use ExUnit.Case

  alias  InfoToml.IndexTree

  setup_all do
    map   = InfoToml.get_map()
    { :ok,
      map:  map
    }
  end

  test "indexes the map", state do
    map   = state.map
    ndx   = IndexTree.index(map)

    assert ndx[:id_num_by_key]  |> is_map()
    assert ndx[:id_nums_by_tag] |> is_map()
    assert ndx[:key_by_id_num]  |> is_map()
  end

end
