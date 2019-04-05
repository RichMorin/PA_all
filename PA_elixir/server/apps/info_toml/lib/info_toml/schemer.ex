defmodule InfoToml.Schemer do
#
# Public functions
#
#   get_schemas/1
#     Load schemas for a tree of TOML files.
#
# Private functions
#
#   do_file/1
#     Process (eg, load) a TOML schema file.
#   do_files/2
#     Perform `file_fun` on each schema file.
#   file_paths/1
#     Get a list of absolute paths to TOML schema files.

  @moduledoc """
  This module generates a collective "schema" data structure, based on a
  schema (`_schema/*.toml`) file.
  """

  alias InfoToml.Parser
  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  Load schemas for a tree of TOML files, given an absolute base path.
  """

  @spec get_schemas(String.t) :: schemas

  def get_schemas(tree_abs) do
    base_len    = byte_size(tree_abs) + 1

    reduce_fn   = fn (x, acc) ->
      { file_abs, file_data }  = x;
      trim_len  = byte_size(file_abs) - base_len

      hash_key  =  file_abs               # "/.../_schemas/main.toml"
      |> binary_part(base_len, trim_len)  # "_schemas/main.toml"

      Map.put(acc, hash_key, file_data)
    end

    tree_abs                              # "/..."
    |> do_files(&do_file/1)               # { "/.../_schemas/*.toml", %{...} }
    |> Enum.reduce(%{}, reduce_fn)        # %{ "..." => %{...}, ... }
  end

  # Private functions

# @spec do_file(s) :: {s, schema} when s: String.t
  @spec do_file(s) :: {s, map | nil} when s: String.t

  defp do_file(file_abs) do
  #
  # Process (eg, load) a TOML schema file.

    file_data = file_abs                  # "/.../_schemas/*.toml"
    |> Parser.parse(:atoms)               # %{meta: %{...}, ...}

    { file_abs, file_data }
  end

  @spec do_files(s, (s -> {s, schema})) :: [ schema ] when s: String.t

  defp do_files(tree_abs, file_fun) do
  #
  # Perform `file_fun` on each schema file.

    tree_abs
    |> file_paths               # get a list of TOML schema files
    |> Enum.map(file_fun)       # load schema data
  end

  @spec file_paths(s) :: [ s ] when s: String.t

  defp file_paths(tree_abs) do
  #
  # Get a list of absolute paths to TOML schema files (`_schemas/*.toml`).

    file_patt  = "/_schemas/*.toml"

    "#{ tree_abs }#{ file_patt }"   # "/.../_schemas/main.toml"
    |> Path.wildcard                # ["/.../main.toml", ...]
  end

end