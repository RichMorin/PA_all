# info_files/cnt_data.ex

defmodule InfoFiles.CntData do
#
# Public functions
#
#   get_data_info/1
#     Return a Map describing the file tree.
#
# Private functions
#
#   add_cnts_by_app/1
#     Add :cnts_by_app  - number of lines of code (etc) by app name.
#   add_cnts_by_ext/1
#     Add :cnts_by_ext  - number of lines of code (etc) by file extension.

  @moduledoc """
  This module implements data file tree counting for InfoFiles, using CntAny
  for the heavy lifting.  At the moment, it counts files, functions (dummied),
  lines, and characters.
  """

  alias InfoFiles.CntAny

  # Public functions

  @doc """
  Return a Map describing a tree of TOML files, eg:

      %{
        cnts_by_dir:    %{ "<dir>"  => %{...}, ... },
        cnts_by_name:   %{ "<name>"  => %{...}, ... },
        cnts_by_path:   %{ "<path>" => %{...}, ... },
        file_paths:     [ "<path>", ... ],
        tree_base:      "<tree_base>",
        tree_bases:     [ "<base>", ... ],
        tracing:        false,
     }

  The Map items are defined as follows:
  
  - `:cnts_by_dir`  - counts by directory name (e.g., `Areas`)
  - `:cnts_by_name` - counts by file name (e.g., `main.toml`)
  - `:cnts_by_path` - counts by file path (e.g., `PA_elixir/.../common.ex`)
  - `:file_paths`   - list of file paths (e.g., `PA_elixir/.../common.ex`)
  - `:tree_base`    - base of the main file tree (e.g., `PA_elixir`)
  - `:tree_bases`   - base of the subsidiary trees (e.g., `PA_elixir/common`)
  - `:tracing`      - boolean control for tracing
  """

  @spec get_data_info(String.t) :: map

  def get_data_info(tree_base) do

    file_info = %{
      tree_base:    tree_base,
      tracing:      false,
    }

    dir_names     = ~w(PA_toml)
    dir_patt      = ""
    file_exts     = ~w(toml)

    file_info
    |> CntAny.add_tree_bases(dir_names)
    |> CntAny.add_file_paths(dir_patt, file_exts)
    |> CntAny.add_cnts_by_path()
    |> add_cnts_by_dir()
    |> add_cnts_by_name()
   end

  # Private functions

  @spec add_cnts_by_dir(map) :: map

  defp add_cnts_by_dir(file_info) do
  #
  # Add `:cnts_by_dir` - a Map of the number of lines of TOML by directory, eg:
  # `%{ "Catalog/Groups" => %{char: 64560, file: 52, line: 2785}, ... }`

    map_fn    = fn file_path ->
      cond do
        file_path =~ ~r{ ^ PA_toml / _ }x   ->
          # PA_toml/_*/*.toml
          pattern   = ~r{ ^ [^/]+ / ( [^/]+ ) / .+ $ }x
          replacer  = "\\1"
          String.replace(file_path, pattern, replacer)

        file_path =~ ~r{ ^ PA_toml / .* / _area\.toml }x   ->
          # PA_toml/**/_area.toml
          pattern   = ~r{ ^ [^/]+ / ( .+ ) / .+ $ }x
          replacer  = "\\1"
          String.replace(file_path, pattern, replacer)

        true -> 
          # Areas/*/*/*.toml
          pattern   = ~r{ ^ [^/]+ / ( [^/]+ / [^/]+ / [^/]+ ) / .+ $ }x
          replacer  = "\\1"
          String.replace(file_path, pattern, replacer)
      end
    end

    CntAny.add_cnts(file_info, :dir, map_fn)
  end

  @spec add_cnts_by_name(map) :: map

  defp add_cnts_by_name(file_info) do
  #
  # Add `:cnts_by_name` - a Map of the number of chars and lines of TOML
  # by file name, eg:
  # `%{ "_area.toml" => %{char: 3558, file: 8, line: 184}, ... }`

    map_fn    = fn file_path -> 
      patt_1    = ~r{ ^ .+ / ( [^/]+ ) \. [^/]+ $ }x
      repl_1    = "\\1.toml"

      patt_2    = ~r{ ^ text \. \w+ \. toml $ }x
      repl_2    = "text.*.toml"

      file_path
      |> String.replace(patt_1, repl_1)
      |> String.replace(patt_2, repl_2)
    end

    CntAny.add_cnts(file_info, :name, map_fn)
  end

end
