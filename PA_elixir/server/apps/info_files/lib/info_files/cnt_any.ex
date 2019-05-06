# info_files/cnt_any.ex

defmodule InfoFiles.CntAny do
#
# Public functions
#
#   add_cnts/3
#     Add :cnts_by_app  - number of lines of code (etc) by app name.
#   add_cnts_by_path/1
#     Add :cnts_by_path - number of lines of code (etc) by file path.
#   add_tree_bases/1
#     Add :tree_bases   - file paths for the base of each code area.
#   add_file_paths/1
#     Add :file_paths   - relative file paths to each code file.
#
# Private Functions
#
#   sum_cols/1
#     Summation helper  - adds a set of "Totals" to `cnts_by_x`.

  @moduledoc """
  This module implements generic file tree counting for InfoFiles.  It counts files,
  functions, lines, and characters.
  """

  import Common

  # Public functions

  @doc """
  Add a specified sub-Map of counts to `file_info`, using a generated key
  (`cnts_by_<file_type>`).  For each file, count files, functions, lines, and
  characters.  The file path is mapped to a sub-key by the function `map_fn`.
  This lets us specify how the input data should be binned and where the
  output data should be stored.
  """

  @spec add_cnts(map, atom, (s->s) ) :: map when s: String.t

  def add_cnts(file_info, file_type, map_fn) do

    cnts_key    = "cnts_by_#{ file_type }" |> String.to_atom()

    reduce_fn   = fn {file_path, file_cnt}, acc ->

      initial     = %{
        char:  file_cnt.char,
        file:  1,
        func:  file_cnt.func,
        line:  file_cnt.line,
      }

      map_key     = map_fn.(file_path)   

      update_fn   = fn curr_val ->
        %{
          char:  curr_val.char + file_cnt.char,
          file:  curr_val.file + 1,
          func:  curr_val.func + file_cnt.func,
          line:  curr_val.line + file_cnt.line,
        }
      end

      Map.update(acc, map_key, initial, update_fn)
    end

    cnt_map     = file_info.cnts_by_path |> Enum.reduce(%{}, reduce_fn)
    counts      = cnt_map |> sum_cols()

    if file_info.tracing do #TG
      ii(counts, cnts_key)
    end

    Map.put(file_info, cnts_key, counts)
  end

  @doc """
  Store a sub-Map of counts in `file_info[:cnts_by_path`].
  For each file path, count files, functions, lines, and characters.
  """

  @spec add_cnts_by_path(map) :: map

  def add_cnts_by_path(file_info) do
    tree_base   = file_info.tree_base
    def_patt    = ~r{ ^ \s+ (def|defp) \s }x

    filter_fn   = fn line -> String.match?(line, def_patt) end

    reduce_fn   = fn file_path, acc ->
      file_text   = "#{ tree_base }/#{ file_path }" |> File.read!()
      file_lines  = file_text  |> String.split("\n")

      char_cnt    = file_text  |> String.codepoints()     |> Enum.count()
      line_cnt    = file_lines                            |> Enum.count()
      func_cnt    = file_lines |> Enum.filter(filter_fn)  |> Enum.count()

      file_cnts   = %{
        char:   char_cnt,
        func:   func_cnt,
        line:   line_cnt,
      }

      Map.put(acc, file_path, file_cnts)
    end

    cnts_by_path = file_info.file_paths
    |> Enum.reduce(%{}, reduce_fn)

    if file_info.tracing do #TG
      path_tuples   = cnts_by_path |> Map.to_list()
#     path_tuples                  |> ii("cnts_by_path (all)")
      path_tuples |> Enum.take(5)  |> ii("cnts_by_path (sample)")
      path_tuples |> Enum.count()  |> ii("cnts_by_path (count)")
    end

    Map.put(file_info, :cnts_by_path, cnts_by_path)
  end

  @doc """
    Given a List of directory names (e.g., `PA_elixir`), store a List of
    tree base strings (e.g., `PA_elixir/common`) in `file_info[:tree_bases`].
  """

  @spec add_tree_bases(map, [String.t] ) :: map

  def add_tree_bases(file_info, dir_names) do

    tree_base   = file_info.tree_base
    prefix      = "#{ tree_base }/"
    name_cnt    = Enum.count(dir_names)

    dir_patt    = if name_cnt > 1 do
      "{#{ Enum.join(dir_names, ",") }}"
    else
      dir_names
    end

    glob_patt   = "#{ prefix }#{ dir_patt }/*"
    map_fn      = fn path -> String.replace_prefix(path, prefix, "") end

    tree_bases  = glob_patt
    |> Path.wildcard()
    |> Enum.map(map_fn)

    if file_info.tracing do #TG
      ii(tree_bases, "tree_bases")
    end

    Map.put(file_info, :tree_bases, tree_bases)
  end

  @doc """
  Store a List of relative file paths (e.g., `PA_elixir/common/lib/common.ex`)
  in `file_info[:file_paths`].  A pattern String (`dir_patt`) and a List of
  file extensions (e.g., `exs`) are used to construct the globbing pattern.
  """
  @spec add_file_paths(map, s, [ s ]) :: map when s: String.t

  def add_file_paths(file_info, dir_patt, file_exts) do

    tree_base   = file_info.tree_base
    prefix      = "#{ tree_base }/"
    file_patt   = "*.{#{ Enum.join(file_exts, ",") }}"

    map_fn      = fn path -> String.replace_prefix(path, prefix, "") end

    reduce_fn   = fn tree_base2, acc ->
      glob_patt   = "#{ prefix }#{ tree_base2 }/#{ dir_patt }" <>
                    "**/#{ file_patt }"

      glob_paths  = Path.wildcard(glob_patt)

      acc ++ glob_paths
    end

    file_paths  = file_info.tree_bases
    |> Enum.reduce([], reduce_fn)
    |> Enum.map(map_fn)

    if file_info.tracing do #TG
      file_paths |> hd() |> ii("file_paths (first)")
    end

    Map.put(file_info, :file_paths, file_paths)
  end

  # Private Functions

  @spec sum_cols(map) :: map

  defp sum_cols(cnts_by_x) do
  #
  # Summation helper - adds a set of "Totals" to `cnts_by_x`.
  # Used by some `add_cnts_by_...` functions in this module.

    reduce_fn   = fn {_key, val}, acc ->
      acc
      |> Map.put(:char, acc.char + val.char)
      |> Map.put(:file, acc.file + val.file)
      |> Map.put(:func, acc.func + val.func)
      |> Map.put(:line, acc.line + val.line)
    end

    base_map  = %{ char: 0, file: 0, func: 0, line: 0 }
    totals    = cnts_by_x |> Enum.reduce(base_map, reduce_fn)
    final     = cnts_by_x |> Map.merge( %{ "|Totals" => totals } )

    final
  end

end
