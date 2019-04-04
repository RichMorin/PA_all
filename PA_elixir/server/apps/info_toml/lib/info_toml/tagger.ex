defmodule InfoToml.Tagger do
#
# Public functions
#
#   get_tag_info/0
#     Return a Map describing tag usage in the TOML files.

  @moduledoc """
  This module implements tag usage analysis for InfoToml.
  """

  import InfoToml.KeyVal

  use InfoToml, :common
  use Common,   :common
  use InfoToml.Types

  # external API

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
    |> add_kv_info(inbt_map, :tags)
  end

end
