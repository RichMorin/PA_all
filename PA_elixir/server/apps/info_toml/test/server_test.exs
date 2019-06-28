# info_toml/test/server_test.exs

defmodule InfoTomlTest.Server do

  use ExUnit.Case

  doctest InfoToml

# @test_file "/Catalog/Hardware/A_/Anova_PC/main.toml"
  @test_key  "Areas/Catalog/Hardware/Anova_PC/main.toml"
  @test_tags [ "Rich_Morin", "f_authors:Rich_Morin" ]

  setup_all do
    { :ok, toml_map: InfoToml.AccessData.get_map() }
  end

  test "loads TOML data", state do
    toml_map    = state.toml_map
    item_map    = toml_map.items[@test_key]

    assert is_map(toml_map)
    assert is_map(item_map)
    assert is_map(item_map.meta)
    assert is_map(item_map.meta.tags)

    assert is_binary(item_map.meta.tags.roles)
  end

  test "indexes TOML data", state do
    toml_ndx    = state.toml_map.index

    assert is_map(toml_ndx)
    assert is_map(toml_ndx.id_num_by_key)
    assert is_map(toml_ndx.key_by_id_num)
    assert is_map(toml_ndx.id_nums_by_tag)

    id_num    = toml_ndx.id_num_by_key[@test_key]
    assert is_integer(id_num)

    item_key  = toml_ndx.key_by_id_num[id_num]
    assert is_binary(item_key)

    test_fn = fn tag ->
    #
    # Run tests on each tag.

      id_nums   = toml_ndx.id_nums_by_tag[tag]
      assert is_map(id_nums)
      assert MapSet.member?(id_nums, id_num)
    end

    tags      = [ "Rich_Morin", "f_authors:Rich_Morin" ]
    Enum.each(tags, test_fn)
  end

  test "serves TOML item data" do
    test_item   = InfoToml.get_item(@test_key)
    assert is_map(test_item)

    id_str      = get_in(test_item, [:meta, :id_str])
    assert id_str == "Anova_PC"
  end

  test "serves TOML main file data" do
    test_fn   = fn tag ->
    #
    # Run tests on each tag.

      expected    = "Areas/Catalog/Software/Emacspeak/main.toml"
      item_keys   = InfoToml.keys_by_tag(tag)
      assert is_list(item_keys)
      assert is_binary(hd(item_keys))
      assert Enum.member?(item_keys, expected)
    end
    
    Enum.each(@test_tags, test_fn)
  end

end
