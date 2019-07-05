# info_files/cnt_data.ex

defmodule InfoFiles.CntData do
#
# Public functions
#
#   get_data_info/1
#     Return a map describing the file tree.
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

  alias Common.Types, as: CT
  alias InfoFiles.CntAny

  # Public functions

  @doc """
  Return a map describing a tree of TOML files, e.g.:

      %{
        cnts_by_dir:    %{ "<dir>"  => %{...}, ... },
        cnts_by_name:   %{ "<name>"  => %{...}, ... },
        cnts_by_path:   %{ "<path>" => %{...}, ... },
        file_paths:     [ "<path>", ... ],
        tree_base:      "<tree_base>",
        tree_bases:     [ "<base>", ... ],
        tracing:        false,
     }

  The map items are defined as follows:
  
  - `:cnts_by_dir`  - counts by directory name (e.g., `Areas`)
  - `:cnts_by_name` - counts by file name (e.g., `main.toml`)
  - `:cnts_by_path` - counts by file path (e.g., `PA_elixir/.../common.ex`)
  - `:file_paths`   - list of file paths (e.g., `PA_elixir/.../common.ex`)
  - `:tree_base`    - base of the main file tree (e.g., `PA_elixir`)
  - `:tree_bases`   - base of the subsidiary trees (e.g., `PA_elixir/common`)
  - `:tracing`      - boolean control for tracing
  """

  @spec get_data_info(String.t) :: CT.info_map

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

  @spec add_cnts_by_dir(im) :: im when im: CT.info_map

  defp add_cnts_by_dir(file_info) do
  #
  # Add `:cnts_by_dir` - a map of the number of lines of TOML by directory, eg:
  # `%{ "Catalog/Groups" => %{char: 64560, file: 52, line: 2785}, ... }`

    dir_fn    = fn file_path ->
    #
    # Convert a file path to the corresponding directory name.

      pattern = case file_path do
        ~r{ ^ PA_toml / _ }x ->                   # PA_toml/_*/*.toml
          ~r{ ^ [^/]+ / ( [^/]+ ) / .+ $ }x

        ~r{ ^ PA_toml / .* / _area\.toml }x ->    # PA_toml/**/_area.toml
          ~r{ ^ [^/]+ / ( .+ ) / .+ $ }x

        _ ->                                      # Areas/*/*/*.toml
          ~r{ ^ [^/]+ / ( [^/]+ / [^/]+ / [^/]+ ) / .+ $ }x
      end

      String.replace(file_path, pattern, "\\1")
    end

    CntAny.add_cnts(file_info, :dir, dir_fn)
  end

  @spec add_cnts_by_name(im) :: im when im: CT.info_map

  defp add_cnts_by_name(file_info) do
  #
  # Add `:cnts_by_name` - a map of the number of chars and lines of TOML
  # by file name, eg:
  # `%{ "_area.toml" => %{char: 3558, file: 8, line: 184}, ... }`

    name_fn   = fn file_path ->
    #
    # Convert a file path to the corresponding file name.
 
      patt_1    = ~r{ ^ .+ / ( [^/]+ ) \. [^/]+ $ }x
      repl_1    = "\\1.toml"

      patt_2    = ~r{ ^ text \. \w+ \. toml $ }x
      repl_2    = "text.*.toml"

      file_path
      |> String.replace(patt_1, repl_1)
      |> String.replace(patt_2, repl_2)
    end

    CntAny.add_cnts(file_info, :name, name_fn)
  end

end
