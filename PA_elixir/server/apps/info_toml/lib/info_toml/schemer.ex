# info_toml/schemer.ex

defmodule InfoToml.Schemer do
#
# Public functions
#
#   get_prefix/0
#     Load the prefix file (.../config/prefix.toml).
#   get_schema/2
#     Work around file system naming vagaries to select the appropriate schema.
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
  This module generates a collective "schemas" data structure,
  based on a collection of schema files (`_schema/*.toml`).
  """

  import InfoToml.Common, only: [get_file_abs: 1]

  alias InfoToml.Parser
  alias InfoToml.Types, as: ITT

  @doc """
  Load the prefix file (`.../config/prefix.toml`).
  """

  @spec get_prefix() :: ITT.schema_map

  def get_prefix() do
    "_config/prefix.toml"
    |> get_file_abs()                   # "/.../_config/prefix.toml"
    |> InfoToml.Parser.parse(:atoms)    # %{ meta: %{...}, ... }
    |> Map.get(:prefix)                 # %{ ext_wp: "...", ... }
  end

  @doc """
  Work around file system naming vagaries to select the appropriate schema.
  """

  @spec get_schema(ITT.schema_map, String.t) :: ITT.schema

  def get_schema(schema_map, file_key) do

    schema_key = cond do
      file_key =~ ~r{ / _area \. toml $ }x            ->  "_schemas/area.toml"
      file_key =~ ~r{ ^ .* / s_\w+ \. toml $ }x       ->  "_schemas/slide.toml"
      file_key =~ ~r{ ^ .* / text \. \w+ \. toml $ }x ->  "_schemas/text.toml"
      file_key =~ ~r{ _text / \w+ \. toml $ }x        ->  "_schemas/text.toml"
      true    ->  String.replace(file_key, ~r{ ^ .+ / }x, "_schemas/")
    end

    schema_map[schema_key]
  end

  @doc """
  Load schemas for a tree of TOML files, given an absolute base path.
  """

  @spec get_schemas(String.t) :: ITT.schema_map

  def get_schemas(tree_abs) do
    base_len    = byte_size(tree_abs) + 1

    schema_fn   = fn x, acc ->
    #
    # Construct a map of schemas. 

      { file_abs, file_data }  = x
      trim_len  = byte_size(file_abs) - base_len

      key  =  file_abs                    # "/.../_schemas/main.toml"
      |> binary_part(base_len, trim_len)  # "_schemas/main.toml"

      Map.put(acc, key, file_data)
    end

    tree_abs                          # "/..."
    |> do_files(&do_file/1)           # { "/.../_schemas/*.toml", %{...} }
    |> Enum.reduce(%{}, schema_fn)    # %{ "_schemas/*.toml" => %{...}, ... }
  end

  # Private functions

  @spec do_file(st) :: {st, ITT.schema | nil}
    when st: String.t

  defp do_file(file_abs) do
  #
  # Process (eg, load) a TOML schema file.

    file_data = file_abs            # "/.../_schemas/*.toml"
    |> Parser.parse(:atoms)         # %{meta: %{...}, ...}

    { file_abs, file_data }
  end

  @spec do_files(st, (st -> {st, sc})) :: [sc]
    when sc: ITT.schema, st: String.t

  defp do_files(tree_abs, file_fn) do
  #
  # Perform `file_fn` on each schema file.

    tree_abs
    |> file_paths                   # get a list of TOML schema files
    |> Enum.map(file_fn)            # load schema data
  end

  @spec file_paths(st) :: [st]
    when st: String.t

  defp file_paths(tree_abs) do
  #
  # Get a list of absolute paths to TOML schema files (`_schemas/*.toml`).

    file_patt  = "/_schemas/*.toml"

    "#{ tree_abs }#{ file_patt }"   # "/.../_schemas/main.toml"
    |> Path.wildcard                # ["/.../main.toml", ...]
  end

end