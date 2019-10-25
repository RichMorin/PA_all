# info_files.ex

defmodule InfoFiles do

  @moduledoc """
  This module defines the external API for the InfoFiles component.  Each
  "function" actually delegates to a public function in `info_files/*.ex`.
  """

  alias InfoFiles.{CntCode, CntData}

  # Define the public interface.

  ## CntCode

  @doc delegate_to: {CntCode, :get_code_info, 1}
  defdelegate get_code_info(tree_base), to: CntCode

  ## CntData

  @doc delegate_to: {CntData, :get_data_info, 1}
  defdelegate get_data_info(tree_base), to: CntData
end
