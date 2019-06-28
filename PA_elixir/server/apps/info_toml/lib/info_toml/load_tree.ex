# info_toml/load_tree.ex

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
#     Get a sorted list of relative paths to TOML files.
#   path_prep/2
#     Convert a list of file paths into a list of numbered tuples.

  @moduledoc """
  This module handles loading of data from a TOML file tree, including
  loading and checking against the schema.
  """

  use Common.Types

  import Common,
    only: [ get_map_max: 1, get_rel_path: 2, get_run_mode: 0 ]
  import InfoToml.Common,
    only: [ get_file_abs: 1, get_map_key: 1, get_tree_abs: 0 ]

  alias InfoToml.{CheckItem, Parser, Schemer}

  # Public functions

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

    item_fn   = fn x, acc ->
    #
    # Construct a map of item information from the TOML tree.

      { file_rel, file_data }  = x
      file_key  = get_map_key(file_rel)
      Map.put(acc, file_key, file_data)
    end

    filter_fn   = fn {_key, val} -> val end
    #
    # Retain tuples that have non-nil values,

    items   = schemas
    |> do_tree(old_map)             # [ { <key>, %{...} }, { <key>, nil }, ...]
    |> Enum.filter(filter_fn)       # [ { <key>, %{...} }, ...]
    |> Enum.reduce(%{}, item_fn)    # %{ <key> => %{...}, ...}

    %{
      items:      items,
#     tree_abs:   tree_abs
    }
  end

  @doc """
  Process (eg, load, check) a TOML file.

  Note: This function is only exposed as public to enable testing. 
  """

  @spec do_file(s, integer, schema_map) :: {s, any} when s: String.t

  def do_file(file_rel, id_num, schema_map) do
 
    file_rel
    |> get_file_abs()
    |> Parser.parse(:atoms!)  # require atom predefinition
    |> do_file_1(file_rel, id_num, schema_map)
  end

  # Private functions

  @spec do_file_1(any, String.t, integer, schema_map) :: tuple

  defp do_file_1(file_data, file_rel, _, _) when file_data == %{} do
    {file_rel, nil}
  end
  #
  # Bail out if `Parser.parse/2` returned an empty Map.

  defp do_file_1(file_data, file_rel, id_num, schema_map) do
  #
  # Unless the key starts with "_", check `file_data` against `schema`.

    file_key  = get_map_key(file_rel)
    file_stat = file_data |> CheckItem.check(file_key, schema_map)

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

    patt_item   = ~r{ / [^/]+ / ( main | make ) \. toml $ }x
    patt_misc   = ~r{ / [^/]+ \. toml $ }x

    directories   = file_key
    |> String.replace(patt_item, "")
    |> String.replace(patt_misc, "")
    |> String.split("/")
    |> Enum.join(", ")

    file_data   = if get_in(file_data, [:meta, :tags]) do
      file_data
    else
      put_in(file_data, [:meta, :tags], %{})
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

  @spec do_tree(schema_map, toml_map | nil) :: [ toml_map ]

  defp do_tree(schema_map, old_map) do
  #
  # Traverse the TOML file tree, attempting to load each file.

    file_fn   = fn {file_rel, id_num} ->
    #
    # Return data from the specified file.

#     Common.ii(file_rel, :file_rel) #T
      do_file(file_rel, id_num, schema_map)
    end

    get_tree_abs()
    |> file_paths()             # get a list of TOML file paths
    |> path_prep(old_map)       # turn into numbered tuples
    |> Enum.map(file_fn)        # load and check file data
    |> Enum.filter( &(&1) )     # discard nil results
  end

  @spec file_paths(s) :: [ s ] when s: String.t

  defp file_paths(tree_abs) do
  #
  # Get a sorted list of relative paths to TOML files.
  # Ignore files in `_tests` unless we're being run in `:test` mode.

    glob_patt   = "#{ tree_abs }/**/*.toml"
    raw_paths   = glob_patt
    |> Path.wildcard()
    |> Enum.sort()

    rel_path_fn = fn file_abs ->
    #
    # Convert the absolute file path to a relative file path.

      get_rel_path(tree_abs, file_abs)
    end

    ignore_fn = fn path ->
    #
    # Return true if file path contains "/ignore".

#     String.starts_with?(path, "Areas/Catalog/") ||  #D Uncomment for testing.
      path =~ ~r{ /_ignore }x
    end

    reject_fn = fn path ->
    #
    # Return true if file path begins with "/_test".

      String.starts_with?(path, "_test/")
    end

    rare_paths  = raw_paths       # [ "/.../_text/about.toml", ... ]
    |> Enum.map(rel_path_fn)      # [ "_text/about.toml", ... ]
    |> Enum.reject(ignore_fn)     # Ignore "/ignore" file paths.

    case get_run_mode() do
      :test -> rare_paths
      _     -> rare_paths |> Enum.reject(reject_fn)
    end
  end

  @spec path_prep([ s ], item_maybe) :: [ {s, integer} ] when s: String.t

  # Convert a list of file paths into a list of numbered tuples.
  # If inp_map is nil, generate new IDs.  Otherwise, use existing
  # IDs where possible and generate new ones for the rest.

  defp path_prep(path_list, nil), do: Enum.with_index(path_list, 1000)
 
  defp path_prep(path_list, inp_map) do

    reduce_fn1  = fn {item_key, _item_id}, inp_acc ->
    #
    # Add a map entry (file_rel => id_num).

      gi_path   = [:items, item_key, :meta]
      meta      = get_in(inp_map, gi_path)
      Map.put(inp_acc, meta.file_rel, meta.id_num)
    end
      
    id_map      = inp_map.items
    |> Enum.reduce(%{}, reduce_fn1)

    max_id    = get_map_max(id_map)

    reduce_fn2 = fn inp_path, inp_acc ->
    #
    # Update the `{ max_id, id_map }` tuple.

      { max_id, id_map } = inp_acc

      item_key  = get_map_key(inp_path)
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

    { _max_id, id_map } = path_list
    |> Enum.reduce(inp_acc, reduce_fn2)

    id_map |> Map.to_list()
  end

end
