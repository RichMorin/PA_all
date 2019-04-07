defmodule InfoToml.Server do
#
# Public functions
#
#   get_item/1
#     Return the data structure for an item, given its key.
#   get_items/1
#     Return a list of items, given a base string for the key.
#   get_keys/1
#     Return a sorted and trimmed list of item keys.
#   get_map/0
#     Return the entire `toml_map` data structure.
#   get_part/1
#     Return a specified portion of `toml_map`.
#   get_toml/1
#     Return the TOML source code, given its key.
#   keys_by_tag/1
#     Return a list of item keys, given a tag value.
#   put_item/2
#     Update an item in toml_map, given its key and value.
#   reload/0
#     Reload and re-index the TOML file tree.
#   start_link/0
#     Start up the server Agent.
#
# Private functions
#
#   first_load/0
#     Handle initial loading of data.
#   toml_load/1
#     Load and index a set of TOML files.

  @moduledoc """
  This module implements both the external API (eg, `get_item/1`) and the
  setup ceremony (eg, `start_link/0`, `build_map/0`) for the OTP server.
  """

  @me __MODULE__

  alias InfoToml.{CheckTree, IndexTree, LoadTree}
  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  # external API

  @doc """
  Return the data structure for an item, given its key (eg, "_text/about.toml").
  """

  @spec get_item(String.t) :: item_map | nil

  def get_item(item_key), do: [:items, item_key] |> get_part()

  @doc """
  Return a list of items (really, `{key, title, precis}` tuples),
  given a base string (eg, "Areas/Catalog/Hardware/") for the key.
  """

  @spec get_items(s) :: { s, s, s } when s: String.t

  def get_items(key_base) do
    map_fn     = fn toml_map ->

      filter_fn   = fn item_key ->
        is_binary(item_key) &&
        String.starts_with?(item_key, key_base)
      end

      reduce_fn = fn (item_key, acc) ->
        precis  = get_in(toml_map, [:items, item_key, :about, :precis])
        title   = get_in(toml_map, [:items, item_key, :meta,  :title])
        tuple   = {item_key, title, precis}
        [ tuple | acc ]
      end

      toml_map.items                  # map containing item data
      |> keyss()                      # sorted list of item keys
      |> Enum.filter(filter_fn)       # keys with the specified base
      |> Enum.reduce([], reduce_fn)   # [ {item_key, title, precis}, ... ]
    end

    Agent.get(@me, map_fn)
  end

  @doc """
  Return a sorted list of item keys, trimmed to a specified number of levels.
  For example:

      1 => ["Catalog"]
      2 => ["Catalog", "Content"]
      3 => ["Catalog", "Content", "_schemas"]
      4 => ["Catalog", "Content", "_schemas", "_text"]
  """

  @spec get_keys(integer) :: [ String.t ]

  def get_keys(levels) do
    max_ndx = levels - 1

    map_fn = fn key ->
      key
      |> String.split("/")
      |> Enum.slice(0..max_ndx)
      |> Enum.join("/")
    end

    get_fn = fn toml_map ->
      toml_map.items
      |> keyss()
      |> Enum.map(map_fn)
      |> Enum.dedup()
    end

    Agent.get(@me, get_fn)
  end

  @doc """
  Return the entire `toml_map` data structure (mostly for testing).
  """

  @spec get_map() :: toml_map

  def get_map() do
    get_fn  = fn toml_map -> toml_map end

    Agent.get(@me, get_fn)
  end

  @doc """
  Return a specified portion of `toml_map`.  If `gi_list` is empty,
  return all of `toml_map`.
  """

  @spec get_part( [ atom | String.t ] ) :: any | nil

  def get_part([]) do
    get_fn = fn toml_map -> toml_map end

    Agent.get(@me, get_fn)
  end

  def get_part(gi_list) do
    get_fn = fn toml_map -> get_in(toml_map, gi_list) end
    Agent.get(@me, get_fn)
  end

  @doc """
  Return the TOML source code, given its key (eg, "_text/about.toml").
  """

  @spec get_toml(String.t) :: String.t

  def get_toml(item_key) do
    gi_path   = [:meta, :file_rel]
    file_rel  = item_key      # "_text/about.toml"
    |> get_item()             # %{about: %{...}, ...}
    |> get_in(gi_path)        # "/.../_text/about.toml"

    if file_rel do
      file_abs = get_file_abs(file_rel)

      case File.read(file_abs) do
        {:ok, body}       -> body
        {:error, _reason} -> nil
      end
    else
      nil
    end
  end

  @doc """
  Return a list of item keys, given a tag value (possibly containing
  a tag name prefix).
  """

  @spec keys_by_tag(String.t) :: [ String.t ]

  def keys_by_tag(tag_val) do
    get_fn  = fn toml_map ->
      map_fn  = fn id_num ->
        gi_path   = [:index, :key_by_id_num, id_num]
        toml_map
        |> get_in(gi_path)      # [1024, 1042, ...]
      end

      gi_path   = [:index, :id_nums_by_tag, tag_val]

      map_set   = get_in(toml_map, gi_path)
      if map_set do
        map_set                 # #MapSet<[1024, 1042, ...]>
        |> MapSet.to_list()       # [1024, 1042, ...]
        |> Enum.map(map_fn)       # ["Catalog/...", ...]
      else
        [] #K Passing back an empty array isn't a big win over crashing...
      end
    end

    Agent.get(@me, get_fn)
  end

  @doc """
  Update an item in toml_map, given its key (eg, "_text/about.toml") and value.
  """

  @spec put_item(s, map) :: atom when s: String.t

  def put_item(key, item), do: put_part(item, [:items, key])

  @doc """
  Replace a specified portion of `toml_map`.  If `key_list` is nil,
  replace `toml_map` entirely.
  """

  @spec put_part(any, [ map_key ] | nil) :: atom

  def put_part(new_val, key_list \\ nil) do
    update_fn = fn toml_map ->
      if key_list == nil do
        new_val
      else
        put_in(toml_map, key_list, new_val)
      end
    end

    Agent.update(@me, update_fn)
  end

  @doc """
  Reload and re-index the TOML file tree.
  """

  @spec reload() :: {atom, String.t}

  def reload() do
    get_fn    = fn cur_map -> cur_map end
    old_map   = Agent.get(@me, get_fn)

    {status, messages, toml_map} = toml_load(old_map)
    msg_str   = "(#{ Enum.join(messages, ", ") })"

    update_fn = fn _ignore -> toml_map end

    case status do
      :ok ->
        Agent.update(@me, update_fn)
        {:info,  "Updated without problems."}
      :warning ->
        Agent.update(@me, update_fn)
        {:error, "Updated with warnings #{ msg_str }."}
      :error ->
        {:error, "Update failed #{ msg_str }."}
    end
  end

  @doc """
  Start up the server Agent.
  """

  @spec start_link() :: {atom, pid | String.t }

  def start_link() do
    Agent.start_link(&first_load/0, name: @me)
  end

  # Private functions

  @spec first_load() :: map

  defp first_load() do
  #
  # Handle initial loading of data.

    {status, messages, toml_map} = toml_load()

    case status do
      :ok   -> toml_map
      _     ->
        IO.puts ">>> Errors in InfoToml.first_load/0:\n"
        IO.puts Enum.join(messages, ", /n")
        IO.puts ""
        exit("Exiting due to global TOML errors.")
        toml_map       #K - Can we cause PhxHttp not to start up?
    end
  end

  @spec toml_load(map | nil) :: {atom, [ String.t ], map}

  defp toml_load(old_map \\ nil) do
  #
  # Load and index a set of TOML files.
  # Used by both `first_load/0` and `reload/0`.

    IO.puts "\n>>> Begin loading TOML files..."

    toml_map    = LoadTree.load(old_map)
    toml_ndx    = IndexTree.index(toml_map)
    toml_map    = Map.put(toml_map, :index, toml_ndx)
    {status, messages} = CheckTree.check_all(toml_map)

#   ii(keyss(toml_map), "keyss(toml_map)") #T
#   ii(toml_ndx, "toml_ndx") #T

    IO.puts "\n>>> End loading TOML files...\n"

    {status, messages, toml_map}
  end

end
