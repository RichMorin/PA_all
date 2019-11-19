# info_toml/load_tree.ex

defmodule InfoToml.LoadTree do
#
# Public functions
#
#   load/1
#     Load a map from the tree of TOML files.
#
# Private functions
#
#   do_tree/2
#     Traverse the TOML file tree, attempting to load each file.
#   file_paths/1
#     Get a sorted list of relative paths to TOML files.
#   path_prep/2
#     Convert a list of file paths into a list of numbered tuples.

  @moduledoc """
  This module handles loading of data from a TOML file tree.
  """

  import Common,
    only: [ get_map_max: 1, get_rel_path: 2, get_run_mode: 0, ssw: 2 ]

  import InfoToml.Common,
    only: [ get_map_key: 1, get_tree_abs: 0 ]

  alias InfoToml.{LoadFile, Schemer}
  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  Load a map from the tree of TOML files, given an (optional) absolute path
  for the tree.
  """

  @spec load(ITT.item_maybe) :: ITT.item_map

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
    # Retain tuples that have non-nil values.

    items   = schemas
    |> do_tree(old_map)             # [ { <key>, %{...} }, { <key>, nil }, ...]
    |> Enum.filter(filter_fn)       # [ { <key>, %{...} }, ...]
    |> Enum.reduce(%{}, item_fn)    # %{ <key> => %{...}, ...}

    %{
      items:      items,
#     tree_abs:   tree_abs
    }
  end

  # Private functions

  @spec do_tree(ITT.schema_map, ITT.toml_map | nil) ::
    [ {String.t, ITT.item_map} ]

  defp do_tree(schema_map, old_map) do
  #
  # Traverse the TOML file tree, attempting to load each file.

    file_fn   = fn {file_rel, id_num} ->
    #
    # Return data from the specified file.

      if false do #!G
        keyss = Common.keyss(schema_map)
        Common.ii(keyss, :keyss)
        Common.ii(file_rel, :file_rel)
      end

      LoadFile.do_file(file_rel, id_num, schema_map)
    end

    get_tree_abs()
    |> file_paths()             # get a list of TOML file paths
    |> path_prep(old_map)       # turn into numbered tuples
    |> Enum.map(file_fn)        # load and check file data
    |> Enum.reject(&is_nil/1)   # discard nil results
  end

  @spec file_paths(st) :: [st, ...]
    when st: String.t

  defp file_paths(tree_abs) do
  #
  # Get a sorted list of relative paths to TOML files.
  # Ignore files in `_tests` unless we're being run in `:test` mode.

    glob_patt   = "#{ tree_abs }/**/*.toml"
    raw_paths   = glob_patt
    |> Path.wildcard()
    |> Enum.sort()

    rel_path_fn = fn file_abs -> get_rel_path(tree_abs, file_abs) end
    #
    # Convert the absolute file path to a relative file path.

    ignore_fn = fn path ->
    #
    # Return true if file path contains "/ignore".

#     ssw(path, "Areas/Catalog/") ||  #!D Uncomment for testing.
      path =~ ~r{ /_ignore }x
    end

    reject_fn = fn path -> ssw(path, "_test/") end
    #
    # Return true if file path begins with "/_test".
   
    rare_paths  = raw_paths       # [ "/.../_text/about.toml", ... ]
    |> Enum.map(rel_path_fn)      # [ "_text/about.toml", ... ]
    |> Enum.reject(ignore_fn)     # Ignore "/ignore" file paths.

    case get_run_mode() do
      :test -> rare_paths
      _     -> rare_paths |> Enum.reject(reject_fn)
    end
  end

  @spec path_prep([st, ...], ITT.item_maybe) :: [ {st, ITT.id_num} ]
    when st: String.t

  # Convert a list of file paths into a list of numbered tuples.
  # If inp_map is nil, generate new IDs.  Otherwise, use existing
  # IDs where possible and generate new ones for the rest.

  defp path_prep(path_list, nil), do: Enum.with_index(path_list, 1000)
 
  defp path_prep(path_list, inp_map) do

    entry_fn  = fn {item_key, _item_id}, inp_acc ->
    #
    # Add a map entry (file_rel => id_num).

      gi_path   = [:items, item_key, :meta]
      meta      = get_in(inp_map, gi_path)
      Map.put(inp_acc, meta.file_rel, meta.id_num)
    end
      
    id_map      = inp_map.items
    |> Enum.reduce(%{}, entry_fn)

    max_id    = get_map_max(id_map)

    tuple_fn  = fn inp_path, inp_acc ->
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
    |> Enum.reduce(inp_acc, tuple_fn)

    id_map |> Map.to_list()
  end

end
