# info_toml/test/tagger_test.exs

defmodule InfoTomlTest.Tagger do

  use ExUnit.Case

  import InfoToml.Trees, only: [ our_tree: 2 ]

  alias     InfoToml.{Reffer, Tagger}

  setup_all do
    ref_info    = Reffer.get_ref_info()
    tag_info    = Tagger.get_tag_info()

    {
      :ok,
      info:   [ ref_info, tag_info ]
    }
  end

  def do_tests(info) do
  #
  # Test whether `info` has the following shape:
  #
  #   %{
  #     tracing:    false,
  #     kv_info:    %{
  #       kv_cnts:    %{ <type>: <count> },
  #       kv_descs:   %{ <type>: <desc> },
  #       kv_list:    [ { <type>, <val>, <cnt> }, ... ],
  #       kv_map:     %{ <type>: %{ <val> => <cnt> }, ... }
  #     }
  #   }

    assert  our_tree(info, false)

    assert  is_boolean    info.tracing
    assert  is_map        info.kv_info
    assert  is_map        info.kv_info.kv_cnts
    assert  is_list       info.kv_info.kv_list
    assert  is_map        info.kv_info.kv_map
  end

  test "returns right shape of data for ref and tag info", state do
    state.info |> Enum.map(&do_tests/1)
  end

end
