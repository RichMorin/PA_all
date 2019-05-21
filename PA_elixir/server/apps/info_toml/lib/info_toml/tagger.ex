# info_toml/tagger.ex

defmodule InfoToml.Tagger do
#
# Public functions
#
#   get_tag_info/0
#     Return a Map describing tag usage in the TOML files.

  @moduledoc """
  This module implements tag usage analysis for InfoToml.
  """

  use Common.Types

  alias InfoToml.KeyVal

  # Public functions

  @doc """
  Return a Map describing tag usage in the TOML files, e.g.

      %{
        tracing:    false,
        kv_info:    %{
          kv_cnts:    %{ <type>: <count> },
          kv_descs:   %{ <type>: <desc> },
          kv_list:    [ { <type>, <val>, <cnt> }, ... ],
          kv_map:     %{ <type>: %{ <val> => <cnt> }, ... }
        }
      }
  """

  @spec get_tag_info() :: map

  def get_tag_info() do
  #
  # Get a map of tag usage information.

    # !!! - Use the :index, Luke...

    index     = InfoToml.get_part([:index])
    inbt_map  = index[:id_nums_by_tag]

    tag_info = %{
      tracing:      false,
    }

    tag_info
    |> KeyVal.add_kv_info(inbt_map, :tags)
  end

end
