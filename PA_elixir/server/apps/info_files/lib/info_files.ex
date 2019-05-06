# info_files.ex

defmodule InfoFiles do

  @moduledoc """
  This module defines the external API for the InfoFiles component.  Each
  "function" actually delegates to a public function in `info_files/*.ex`.
  """

  alias InfoFiles.{CntCode, CntData}

  # Define the public interface.

  @doc """
  Return a Map describing the code files.
  ([`...CntCode.get_code_info/1`](InfoFiles.CntCode.html#get_code_info/1))
  """
  defdelegate get_code_info(tree_base),             to: CntCode

  @doc """
  Return a Map describing the TOML files.
  ([`...CntData.get_data_info/1`](InfoFiles.CntData.html#get_data_info/1))
  """
  defdelegate get_data_info(tree_base),             to: CntData

end
