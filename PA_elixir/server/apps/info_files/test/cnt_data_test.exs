# cnt_data_test.exs

defmodule InfoFilesTest.CntData do

  use ExUnit.Case

  setup_all do
    import Common, only: [ get_tree_base: 0 ]

    tree_base   = get_tree_base()
    { :ok, file_info: InfoFiles.CntData.get_data_info(tree_base) }
  end

  test "creates expected data structure", state do
    import Common, only: [ keyss: 1, ssw: 2 ]

    file_info   = state.file_info
    assert is_map(file_info)

    # cnts_by_dir:    %{ "<dir>"  => %{...}, ... },
    # cnts_by_name:   %{ "<name>"  => %{...}, ... },
    # cnts_by_path:   %{ "<path>" => %{...}, ... },
    # file_paths:     [ "<path>", ... ],
    # tree_base:      "<tree_base>",
    # tree_bases:     [ "<base>", ... ],
    # tracing:        false,

    cbd   = file_info.cnts_by_dir
    cbn   = file_info.cnts_by_name
    cbp   = file_info.cnts_by_path

    for val0 <- [cbd, cbn, cbp] do
      assert is_map(val0)           # %{ "<ext>"  => %{...}, ... }
      key1  = keyss(val0) |> hd()
      assert is_binary(key1)        # "<ext>"
      val1  = val0[key1]
      assert is_map(val1)           # %{char: 8951, file: 10, ...}
      key2  = keyss(val1) |> hd()
      assert is_atom(key2)          # :char
      val2  = val1[key2]
      assert is_number(val2)        # 8951
      assert val2 > 0               # 8951
    end

    fp    = file_info.file_paths
    tb    = file_info.tree_bases

    for val0 <- [fp, tb] do
      assert is_list(val0)          # [ "<path>", ... ]
      val1  = hd(val0)
      assert is_binary(val1)        # "<path>"
      assert ssw(val1, "PA_toml/Areas")
    end

    assert is_binary(file_info.tree_base)
    assert is_boolean(file_info.tracing)
  end
end
