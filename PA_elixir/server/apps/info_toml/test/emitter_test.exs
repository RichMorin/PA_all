# emitter_test.exs

defmodule InfoTomlEmitterTest do

  use ExUnit.Case

  import Common
  alias  InfoToml.Emitter

  setup_all do
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
      min_map:  min_map
    }
  end

  test "emits file and returns file path" do
    base_path   = "/tmp"
    toml_text   = "This is a text.\nThis is only a text."
    file_path   = Emitter.emit_toml(base_path, toml_text)

    # "/tmp/2019-03-20T03/2019-03-20T03:18:43.276976Z.toml"
    pattern     = ~r<
      ^ /tmp/
      (\d{4}-\d{2}-\d{2}T\d{2}) /
      \1 :\d{2}:\d{2}\.\d{6}Z\.toml $
    >x
    assert file_path =~ pattern

    file_data   = File.read!(file_path)
    assert file_data == toml_text <> "\n\n\n"
  end

  test "generates TOML", state do
    item_map  = state.min_map
    gi_bases  = [[:about], [:meta]]

    test_toml =
      [
        "# id_str/main.toml\n",
        [
          [ "\n[ meta ]\n\n",
            "  actions     = ", "'actions'\n",
            "  id_str      = ", "'id_str'\n" ],
          [ "\n[ about ]\n\n",
            "  precis      = ", "'precis'\n",
            "  verbose     = ", "'verbose'\n" ]
        ],
        "\n"
      ]

    item_toml = Emitter.get_item_toml(gi_bases, item_map)

    assert item_toml == test_toml
  end

end
