# info_files/cnt_code.ex

defmodule InfoFiles.CntCode do
#
# Public functions
#
#   get_code_info/0
#     Return a Map describing the PA_elixir file tree.
#
# Private functions
#
#   add_cnts_by_app/1
#     Add :cnts_by_app  - number of lines of code (etc) by app name.
#   add_cnts_by_ext/1
#     Add :cnts_by_ext  - number of lines of code (etc) by file extension.

  @moduledoc """
  This module implements code tree counting for InfoFiles, using CntAny
  for the heavy lifting.  At the moment, it counts files, functions,
  lines, and characters.
  """

  alias InfoFiles.CntAny

  # Public functions

  @doc """
  Return a Map describing a tree of code files, eg:

      %{
        cnts_by_app:    %{ "<app>"  => %{...}, ... },
        cnts_by_ext:    %{ "<ext>"  => %{...}, ... },
        cnts_by_path:   %{ "<path>" => %{...}, ... },
        file_paths:     [ "<path>", ... ],
        tree_base:      "<tree_base>",
        tree_bases:     [ "<base>", ... ],
        tracing:        false,
      }

  The Map items are defined as follows:
  
  - `:cnts_by_app`  - counts by application name (e.g., `InfoFiles`)
  - `:cnts_by_ext`  - counts by file extension (e.g., `toml`)
  - `:cnts_by_path` - counts by file path (e.g., `PA_elixir/.../common.ex`)
  - `:file_paths`   - list of file paths (e.g., `PA_elixir/.../common.ex`)
  - `:tree_base`    - base of the main file tree (e.g., `PA_elixir`)
  - `:tree_bases`   - base of the subsidiary trees (e.g., `PA_elixir/common`)
  - `:tracing`      - boolean control for tracing
  """

  @spec get_code_info(String.t) :: map

  def get_code_info(tree_base) do

    file_info = %{
      tree_base:    tree_base,
      tracing:      false,
    }

    dir_names     = ~w(PA_elixir/server/apps)
    dir_list      = ~w(lib test)
    dir_patt      = "{#{ Enum.join(dir_list, ",") }}/"
    file_exts     = ~w(eex ex exs md toml)

    file_info
    |> CntAny.add_tree_bases(dir_names)
    |> CntAny.add_file_paths(dir_patt, file_exts)
    |> CntAny.add_cnts_by_path()
    |> add_cnts_by_app()
    |> add_cnts_by_ext()
   end

  # Private functions

  @spec add_cnts_by_app(map) :: map

  defp add_cnts_by_app(file_info) do
  #
  # Add `:cnts_by_app` - number of lines of code (etc) by app name.

    map_fn    = fn file_path -> 
      pattern     = ~r{ ^ \w+ /server/apps/ (\w+) / .+ $ }x
      replacer    = "\\1"                         # "<app>"

      String.replace(file_path, pattern, replacer)
    end

    CntAny.add_cnts(file_info, :app, map_fn)
  end

  @spec add_cnts_by_ext(map) :: map

  defp add_cnts_by_ext(file_info) do
  #
  # Add `:cnts_by_ext` - number of lines of code (etc) by file extension.

    map_fn    = fn file_path -> 
      pattern     = ~r{ ^ .+ \. }x                # "...<ext>"
      replacer    = ""                            # "<ext>"

      String.replace(file_path, pattern, replacer)
    end

    CntAny.add_cnts(file_info, :ext, map_fn)
  end

end
