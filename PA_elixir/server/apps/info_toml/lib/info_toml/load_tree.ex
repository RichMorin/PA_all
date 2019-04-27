defmodule InfoToml.LoadTree do
#
# Public functions
#
#   load/1
#     Load a map from the tree of TOML files.
#   do_file/3
#     Process (eg, load, check) a TOML file.    # Public only for testing.
#
# Private functions
#
#   do_file_1/4
#     Bail out if `Parser.parse/2` returned `nil`.
#   do_file_2/5
#     Bail out if `CheckItem.check/3` returned `false`.
#   do_tree/2
#     Traverse the TOML file tree, attempting to load each file.
#   file_paths/1
#     Get a list of relative paths to TOML files.
#   get_key/1
#     Convert a relative TOML file path into a map key.
#   path_prep/2
#     Convert a list of file paths into a list of numbered tuples.
#   path_prep_max/1
#     Get the maximum value of a map.
#   rel_path/2
#     Convert an absolute TOML file path into a relative path.

  @moduledoc """
  This module handles loading of data from a TOML file tree, including
  loading and checking against the schema.
  """

  alias InfoToml.{CheckItem, Parser, Schemer}
  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  Load a map from the tree of TOML files, given an (optional) absolute path
  for the tree.
  """

  @spec load(item_maybe) :: item_map

  def load(old_map \\ nil) do
  #
  # Files that don't load have a value of nil, so we filter them out.
  # If old_map is available, we use it to look up and reuse the old
  # id_num values.

    tree_abs    = get_tree_abs()
    schemas     = Schemer.get_schemas(tree_abs)

    reduce_fn   = fn (x, acc) ->
      { file_rel, file_data }  = x;
      file_key  = get_key(file_rel)
      Map.put(acc, file_key, file_data)
    end

    filter_fn   = fn {_key, val} -> val end

    items   = schemas
    |> do_tree(old_map)               # [ { <key>, %{...} }, nil, ...]
    |> Enum.filter(filter_fn)         # [ { <key>, %{...} }, ...]
    |> Enum.reduce(%{}, reduce_fn)    # %{ <key> => %{...}, ...}

    %{
      items:      items,
#     tree_abs:   tree_abs
    }
  end

  @doc """
  Process (eg, load, check) a TOML file.

  Note: This function is only exposed as public to enable testing. 
  """

  @spec do_file(s, integer, map) :: {s, any} when s: String.t

  def do_file(file_rel, id_num, schemas) do
 
    file_rel
    |> get_file_abs()
    |> Parser.parse(:atoms!)  # require atom predefinition
    |> do_file_1(file_rel, id_num, schemas)
  end

  # Private functions

  @spec do_file_1(any, String.t, integer, map) :: tuple

  defp do_file_1(file_data, file_rel, _, _) when file_data == %{} do
    {file_rel, nil}
  end
  #
  # Bail out if `Parser.parse/2` returned an empty Map.

  defp do_file_1(file_data, file_rel, id_num, schemas) do
  #
  # Unless the key starts with "_", check `file_data` against `schema`.

    file_key  = get_key(file_rel)
    file_stat = file_data |> CheckItem.check(file_key, schemas)

    do_file_2(file_data, file_key, file_rel, file_stat, id_num)
  end

  @spec do_file_2(any, any, String.t, boolean, integer) :: tuple

  defp do_file_2(_, _, file_rel, _file_stat = false, _) do
  #
  # Bail out if `CheckItem.check/3` returned `false`.

    {file_rel, nil}
  end

  defp do_file_2(file_data, file_key, file_rel, _file_stat, id_num) do
  #
  # Otherwise, return the harvested (and slightly augmented) data.

    file_abs           = get_file_abs(file_rel)
    {:ok, file_stat}   = File.stat(file_abs, time: :posix)

    directories   = file_key
    |> String.replace(~r{ / [^/]+ / ( main | make ) \. toml $ }x, "")
    |> String.replace(~r{ / [^/]+ \. toml $ }x, "")
    |> String.split("/")
    |> Enum.join(", ")

    file_data   = if !get_in(file_data, [:meta, :tags]) do
      put_in(file_data, [:meta, :tags], %{})
    else
      file_data
    end

    tag_map     = file_data |> get_in([:meta, :tags])

    tag_map     = if file_key != "_schemas/main.toml" do #K
      reduce_fn   = fn {inp_key, inp_val}, acc ->
        tmp_val   = String.replace(inp_val, ~r{\w+\|}, "")
        Map.put(acc, inp_key, tmp_val)
      end

      ref_map   = ( get_in(file_data, [:meta, :refs]) || %{} )
      |> Enum.reduce(%{}, reduce_fn)

      Map.merge(tag_map, ref_map)
    else
      tag_map
    end

    file_data   = file_data
    |> put_in([:meta, :file_key],             file_key)
    |> put_in([:meta, :file_rel],             file_rel)
    |> put_in([:meta, :file_time],            file_stat.mtime)
    |> put_in([:meta, :id_num],               id_num)
    |> put_in([:meta, :tags],                 tag_map)
    |> put_in([:meta, :tags, :directories],   directories)

    { file_rel, file_data }
  end

  @spec do_tree(schemas, toml_maybe) :: [ toml_map ]

  defp do_tree(schemas, old_map) do
  #
  # Traverse the TOML file tree, attempting to load each file.

    file_fn   = fn {file_rel, id_num} ->
      do_file(file_rel, id_num, schemas)
    end

    filter_fn = fn x -> x end

    get_tree_abs()
    |> file_paths()             # get a list of TOML file paths
    |> path_prep(old_map)       # turn into numbered tuples
    |> Enum.map(file_fn)        # load and check file data
    |> Enum.filter(filter_fn)   # discard nil results
  end

  @spec file_paths(s) :: [ s ] when s: String.t

  defp file_paths(tree_abs) do
  #
  # Get a list of relative paths to TOML files.
  # Ignore files in `_tests` unless we're being run in `:test` mode.

    glob_patt   = "#{ tree_abs }/**/*.toml"
    raw_paths   = Path.wildcard(glob_patt)

    map_fn      = fn file_abs ->
      rel_path(tree_abs, file_abs)
    end

    reject_fn_1 = fn path ->
#     String.starts_with?(path, "Areas/Catalog/") ||  #D Uncomment for testing.
      path =~ ~r{ /_ignore }x
    end

    reject_fn_2 = fn path ->
      String.starts_with?(path, "_test/")
    end

    rare_paths  = raw_paths       # [ "/.../_text/about.toml", ... ]
    |> Enum.map(map_fn)           # [ "_text/about.toml", ... ]
    |> Enum.reject(reject_fn_1)   # Reduce number of files.

    case get_run_mode() do
      :test -> rare_paths
      _     -> rare_paths
               |> Enum.reject(reject_fn_2)
    end
  end

  @spec get_key(s) :: s when s: String.t

  defp get_key(file_rel) do
  #
  # Convert a relative TOML file path into a map key, removing any
  # alphabetical sharding directories (eg, "/A_/").

    Regex.replace(~r{/[A-Z]_/}, file_rel, "/")
  end

  @spec path_prep([ s ], item_maybe) :: [ {s, integer} ] when s: String.t

  # Convert a list of file paths into a list of numbered tuples.
  # If inp_map is nil, generate new IDs.  Otherwise, use existing
  # IDs where possible and generate new ones for the rest.

  defp path_prep(path_list, nil), do: Enum.with_index(path_list, 1000)
 
  defp path_prep(path_list, inp_map) do

    reduce_fn1  = fn ({item_key, _item_id}, inp_acc) ->
      gi_path   = [:items, item_key, :meta]
      meta      = get_in(inp_map, gi_path)
      Map.put(inp_acc, meta.file_rel, meta.id_num)
    end
      
    id_map      = inp_map.items
    |> Enum.reduce(%{}, reduce_fn1)

    max_id    = path_prep_max(id_map)

    reduce_fn2 = fn (inp_path, inp_acc) ->
      { max_id, id_map } = inp_acc

      item_key  = get_key(inp_path)
      gi_path   = [:items, item_key]
      item_val  = get_in(inp_map, gi_path)

      if item_val do
        inp_acc
      else
        max_id    = max_id + 1
        id_map    = Map.put(id_map, inp_path, max_id)
        { max_id, id_map }
      end
    end

    inp_acc   = { max_id, id_map }

    reduced   = path_list
    |> Enum.reduce(inp_acc, reduce_fn2)

    { _max_id, id_map } = reduced

    id_map |> Map.to_list()
  end

  @spec path_prep_max( %{String.t => i} ) :: i when i: integer

  def path_prep_max(inp_map) do
  #
  # Get the maximum value of a map.

    reduce_fn   = fn ({_key, val}, acc) -> max(val, acc) end

    inp_map |> Enum.reduce(0, reduce_fn)
  end

  @spec rel_path(s, s) :: s when s: String.t

  defp rel_path(tree_abs, file_abs) do
  #
  # Convert an absolute TOML file path into a relative path.

    base_len  = byte_size(tree_abs) + 1
    trim_len  = byte_size(file_abs) - base_len

    file_abs |> binary_part(base_len, trim_len)
  end

end
