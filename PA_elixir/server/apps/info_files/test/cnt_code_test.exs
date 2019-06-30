# cnt_code_test.exs

defmodule InfoFilesTest.CntCode do

  use ExUnit.Case

  setup_all do
    import Common, only: [ get_tree_base: 0 ]

    tree_base   = get_tree_base()
    { :ok, file_info: InfoFiles.CntCode.get_code_info(tree_base) }
  end

  test "creates expected data structure", state do
    import Common, only: [ keyss: 1, ssw: 2 ]

    # cnts_by_app:    %{ "<app>"  => %{...}, ... },
    # cnts_by_ext:    %{ "<ext>"  => %{...}, ... },
    # cnts_by_path:   %{ "<path>" => %{...}, ... },
    # file_paths:     [ "<path>", ... ],
    # tree_bases:     [ "<base>", ... ],
    # tree_base:      "<tree_base>",
    # tracing:        false,

    file_info   = state.file_info
    assert is_map(file_info)

    cba   = file_info.cnts_by_app
    cbe   = file_info.cnts_by_ext
    cbp   = file_info.cnts_by_path

    for val0 <- [cba, cbe, cbp] do
      assert is_map(val0)           # %{ "<app_name>"  => %{...}, ... }
      key1  = keyss(val0) |> hd()
      assert is_binary(key1)        # "<app_name>"
      val1  = val0[key1]
      assert is_map(val1)           # %{char: 8951, file: 10, ...}
      key2  = keyss(val1) |> hd()
      assert is_atom(key2)          # :char
      val2  = val1[key2]
      assert is_number(val2)        # 8951
      assert val2 > 0               # 8951
    end

    cb    = file_info.tree_bases
    fp    = file_info.file_paths

    for val0 <- [cb, fp] do
      assert is_list(val0)          # [ "<file_path>", ... ]
      val1  = hd(val0)
      assert is_binary(val1)        # "<file_path>"
      assert ssw(val1, "PA_elixir/")
    end

    assert is_binary(file_info.tree_base)
    assert is_boolean(file_info.tracing)
  end
end
