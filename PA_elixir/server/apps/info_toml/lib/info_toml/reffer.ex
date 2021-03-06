# info_toml/reffer.ex

defmodule InfoToml.Reffer do
#
# Public functions
#
#   get_ref_info/0
#     Return a map describing ref usage in the TOML files.

  @moduledoc """
  This module implements ref usage analysis for `InfoToml`.
  """

  alias InfoToml.KeyVal
  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  Return a map describing ref usage in the TOML files, e.g.:

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

  @spec get_ref_info() :: ITT.kv_all

  def get_ref_info() do
  #
  # Get a map of ref usage information.

    # !!! - Use the :index, Luke...

    index     = InfoToml.get_part([:index])
    inbt_map  = index[:id_nums_by_tag]
    ref_info  = %{ tracing: false }

    ref_info
    |> KeyVal.add_kv_info(inbt_map, :refs)
  end
 
end
