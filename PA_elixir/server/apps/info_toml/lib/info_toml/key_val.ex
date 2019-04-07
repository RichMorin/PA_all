defmodule InfoToml.KeyVal do
#
# Public functions
#
#   add_kv_info/3
#     Add a Map of key/value type information.
#
# Private functions
#
#   get_kv_cnts/1
#     Get a Map of usage counts by type.
#   get_kv_descs/0
#     Get a Map of tag type descriptions.
#   get_kv_info/[12]
#     Get a Map of information on typed values (kv).
#   get_kv_list/1
#     Get a List of typed tag tuples.
#   get_kv_map/1
#     Get a two-level Map counts by type and value.
#   gkl_filter/1
#     Retain strings that contain a colon (":").
#   gkl_map/2
#     Look up a list of value strings in `tag_map`.

  @moduledoc """
  This module implements key/value usage analysis for InfoToml.
  """

  use InfoToml, :common
  use Common,   :common
  use InfoToml.Types

  # external API

  @doc """
  Add a Map of key/value information.
  """

  @spec add_kv_info(map, map, atom) :: map

  def add_kv_info(context, inbt_map, subset) do
  #
  # Add a Map of kv type information to the context Map.

    kv_info  = get_kv_info(inbt_map, subset)
    Map.put(context, :kv_info, kv_info)
  end

  # Private functions

  @spec get_kv_cnts(map) :: map

  defp get_kv_cnts(inbt_map) do   # TODO - remove this because unused?
  #
  # Get a Map of usage counts by tag type.

    filter_fn   = fn {key, _val} -> String.contains?(key, ":") end

    reduce_fn1  = fn {key, inp_set}, acc ->
      update_fn     = fn old_set -> MapSet.union(old_set, inp_set) end
      [type, _tag]  = String.split(key, ":")
      type_atom     = String.to_atom(type)

      Map.update(acc, type_atom, inp_set, update_fn)
    end

    reduce_fn2  = fn {key, inp_set}, acc ->
      count     = inp_set
      |> MapSet.to_list()
      |> Enum.count()

      Map.put(acc, key, count)
    end

    sort_fn     = fn {key, _val} -> key end

    inbt_map                        # %{ "..." => #MapSet<[...]>, ... }
    |> Enum.filter(filter_fn)       # { "<type>:...", #MapSet<[...]>, ... }
    |> Enum.sort_by(sort_fn)        # { "<type>:...", #MapSet<[...]>, ... }
    |> Enum.reduce(%{}, reduce_fn1) # %{ <type>: #MapSet<[...]>, ... }
    |> Enum.reduce(%{}, reduce_fn2) # %{ <type>: <count>, ... }
#   |> ii("kv_cnts") #T
  end

  @spec get_kv_descs(atom) :: map

  defp get_kv_descs(subset) do
  #
  # Get a Map of key/value type descriptions.

    schema    = InfoToml.get_item("_schemas/main.toml")
    gi_path   = [:meta, subset]
    kv_descs  = get_in(schema, gi_path)

    if subset == :tags do
      Map.put(kv_descs, :directories, "directory nodes on item's path") #K
    else
      kv_descs
    end
  end

  # Get a Map of information on typed tags (kv).  If called without `inbt_map`,
  # it gets a copy on its own.

  @spec get_kv_info(atom) :: map

  defp get_kv_info(subset) do
    [:index, :id_nums_by_tag]
    |> InfoToml.get_part()
    |> get_kv_info(subset)
  end
  
  @spec get_kv_info(map, atom) :: map

  defp get_kv_info(inbt_map, subset) do

    kv_descs  = get_kv_descs(subset)

    filter_fn = fn {key_str, _val} ->
      key_list  = String.split(key_str, ":")

      if Enum.count(key_list) == 2 do
        key_type  = hd(key_list) |> String.to_atom()
        kv_descs[key_type]
      end
    end

    sub_map   = inbt_map
    |> Enum.filter(filter_fn)
    |> Enum.into(%{})

    kv_cnts   = sub_map  |> get_kv_cnts()
    kv_list   = sub_map  |> get_kv_list()
    kv_map    = kv_list  |> get_kv_map()

    %{
      kv_cnts:   kv_cnts,
      kv_descs:  kv_descs,
      kv_list:   kv_list,
      kv_map:    kv_map,
    }
  end

  @spec get_kv_list(map) :: list

  defp get_kv_list(inp_map) do
  #
  # Get a List of typed tag tuples.
  # (Tally the number of times a tag value is used for a given type.)

    inp_map                         # %{ "<type>:..." => #MapSet<[...]>, ... }
    |> keyss()                      # [ "<type>:...", ... ]
    |> gkl_filter()                 # [ "<type>", ... ]
    |> gkl_map(inp_map)             # [ { :<type>, "<tag>", <cnt> }, ... ]
#   |> ii("kv_list") #T
  end

  @spec get_kv_map( [ String.t ]) :: map

  defp get_kv_map(kv_list) do
  #
  # Get a two-level Map of counts by type and tag.
  # (Tally the number of times each tag value is used for each type.)

    reduce_fn = fn {tag_type, tag_val, count}, acc ->
      initial     = %{ tag_val => count }
      update_fn   = fn old_val -> Map.put(old_val, tag_val, count) end

      Map.update(acc, tag_type, initial, update_fn)
    end

    Enum.reduce(kv_list, %{}, reduce_fn)
  end

  @spec gkl_filter( [ s ] ) :: [ s ] when s: String.t

  defp gkl_filter(input) do
  #
  # Retain strings that contain a colon (":").  That is, tags with types.
  # Used by `get_kv_list`.

    filter_fn = fn key -> String.contains?(key, ":") end

    Enum.filter(input, filter_fn)
  end

  @spec gkl_map([s], map) :: [{atom, s, integer}] when s: String.t

  defp gkl_map(tags, tag_map) do
  #
  # Look up a list of tags in `tag_map`.  Returns a tuple containing the
  # type atom, the tag value, and the usage count.
  # Used by `get_kv_list`.

    map_fn    = fn key ->
      [tag_type, tag_val] = String.split(key, ":")
      type_atom   = String.to_atom(tag_type)
      count       = MapSet.size(tag_map[key])

      {type_atom, tag_val, count}
    end

    Enum.map(tags, map_fn)
  end

end
