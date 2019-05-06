# info_toml/perkian.ex

defmodule InfoToml.Perkian do
#
# Public functions
#
#   get_toml/1
#     Generate a TOML string for use in controlling a build.

  @moduledoc """
  This module contains functions to support the building of Perkian archives.
  """

  # Public functions

  @doc """
  Generate a TOML string for use in controlling a build.  A sample entry
  should look something like this:
  
      [ 'Atril' ]

        actions     = 'build, publish'
        package     = 'ext_pd|stretch/atril'
        precis      = 'the official document viewer for MATE'
  """

  @spec get_toml(atom) :: String.t

  def get_toml(target) do
    key_base   = "Areas/Catalog/Software/"
    |> TomlInfo.get_items()

    # WIP

  end

  # Private functions

  defp get_toml_h(target) do
  #
  # Get target-specific information.
  
    # WIP

  end

end
