# info_toml/test/key_val_test.exs

defmodule InfoTomlTest.KeyVal do

  use ExUnit.Case

  alias  InfoToml.{IndexTree, KeyVal}

  setup_all do
    map   = InfoToml.get_map()
    ndx   = IndexTree.index(map)

    { :ok, ndx: ndx }
  end

  defp do_tests(state, subset, inp_key) do
    context     = %{tracing: false}
    inbt_map    = state.ndx.id_nums_by_tag
    test_map    = KeyVal.add_kv_info(context, inbt_map, subset)

    kv_info     = test_map[:kv_info]
    test_cnts   = get_in(kv_info, [:kv_cnts,  inp_key])
    test_descs  = get_in(kv_info, [:kv_descs, inp_key])
    assert is_number(test_cnts)
    assert is_binary(test_descs)

    kv_list     = kv_info[:kv_list]
    { key, val, cnt } = hd(kv_list)
    assert is_atom(key)
    assert is_binary(val)
    assert is_number(cnt)

    kv_map      = kv_info[:kv_map]
    test_map    = kv_map[inp_key]
    assert is_map(test_map)

    tracing     = test_map[:tracing]
    assert is_atom(tracing)
  end

  test "returns right shape of data for :refs", state do
    do_tests(state, :refs, :f_authors)
  end

  test "returns right shape of data for :tags", state do
    do_tests(state, :tags, :directories)
  end

end
