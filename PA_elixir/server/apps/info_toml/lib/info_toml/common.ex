defmodule InfoToml.Common do
#
# Public macros
#
#   get_tree_abs/0
#     Calculate the absolute path to PA_toml.
#
# Public functions
#
#   get_file_abs/1
#     Convert a relative TOML file path into an absolute path.

  @moduledoc """
  This module contains general purpose functions and macros for use in InfoToml.
  """

  use InfoToml.Types

  @doc """
  Get the absolute file path for the TOML tree.
  
      iex> ta = get_tree_abs()
      iex> ta =~ ~r{ ^ / .* / PA_all / PA_toml $ }x
      true
  """

  @spec get_tree_abs() :: String.t

  defmacro get_tree_abs() do
  #
  # Calculate the absolute path to PA_toml, then generate a hard-coded
  # function to return it.
  #
  # Note: This defmacro must precede the get_file_abs/0 definition!

    offset    = String.duplicate("/..", 7)
    tree_rel  = "#{ __ENV__.file }#{ offset }/PA_toml"
    Path.expand(tree_rel)
  end

  @doc """
  Convert a relative TOML file path into an absolute path.

      iex> fa = get_file_abs("foo")
      iex> fa =~ ~r{ ^ / .* / PA_all / PA_toml / foo $ }x
      true
  """

  @spec get_file_abs(s) :: s when s: String.t

  def get_file_abs(file_rel), do: "#{ get_tree_abs() }/#{ file_rel }"

end
