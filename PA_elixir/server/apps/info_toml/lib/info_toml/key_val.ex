# info_toml/key_val.ex

defmodule InfoToml.KeyVal do
#
# Public functions
#
#   add_kv_info/3
#     Add a map of key/value type information.
#
# Private functions
#
#   get_kv_cnts/1
#     Get a map of usage counts by type.
#   get_kv_descs/0
#     Get a map of tag type descriptions.
#   get_kv_info/[12]
#     Get a map of information on typed values (kv).
#   get_kv_list/1
#     Get a list of typed tag tuples.
#   get_kv_map/1
#     Get a two-level map counts by type and value.
#   get_tuples/2
#     Look up a list of value strings in `tag_map`.
#   get_typed/1
#     Retain typed tags (i.e., strings that contain a colon.

  @moduledoc """
  This module implements key/value usage analysis for InfoToml.
  """

  use Common.Types

  import Common, warn: false, only: [ ii: 2, keyss: 1, sort_by_elem: 2 ]

  # Public functions

  @doc """
  Add a map of key/value information.
  """

  @spec add_kv_info(map, map, atom) :: map

  def add_kv_info(context, inbt_map, subset) do
  #
  # Add a map of key/value (kv) type information to the context map.

    kv_info  = get_kv_info(inbt_map, subset)
    Map.put(context, :kv_info, kv_info)
  end

  # Private functions

  @spec get_kv_cnts(map) :: map

  defp get_kv_cnts(inbt_map) do   # ToDo - remove this because unused?
  #
  # Get a map of usage counts by tag type.

    filter_fn   = fn {key, _val} -> String.contains?(key, ":") end
    #
    # Return true if this tag is typed.

    reduce_fn1  = fn {key, inp_set}, acc ->
    #
    # Return a map of MapSets, indexed by tag type.

      update_fn     = fn old_set -> MapSet.union(old_set, inp_set) end
      #
      # Add a MapSet to the map, indexed by tag type.

      [type, _tag]  = String.split(key, ":")
      type_atom     = String.to_atom(type)

      Map.update(acc, type_atom, inp_set, update_fn)
    end

    reduce_fn2  = fn {key, inp_set}, acc ->
    #
    # Create a map of MapSet counts, indexed by tag type.

      count     = inp_set
      |> MapSet.to_list()
      |> Enum.count()

      Map.put(acc, key, count)
    end

    inbt_map                        # %{ "..." => #MapSet<[...]>, ... }
    |> Enum.filter(filter_fn)       # { "<type>:...", #MapSet<[...]>, ... }
    |> sort_by_elem(0)              # same, but sorted by keys.
    |> Enum.reduce(%{}, reduce_fn1) # %{ <type>: #MapSet<[...]>, ... }
    |> Enum.reduce(%{}, reduce_fn2) # %{ <type>: <count>, ... }
#   |> ii("kv_cnts") #T
  end

  @spec get_kv_descs(atom) :: map

  defp get_kv_descs(subset) do
  #
  # Get a map of key/value type descriptions.

    schema    = InfoToml.get_item("_schemas/main.toml")
    gi_path   = [:meta, subset]
    kv_tags   = get_in(schema, gi_path)

    if subset == :tags do
      gi_path   = [:meta, :refs]
      kv_refs   = get_in(schema, gi_path)

      kv_harv   = %{
        _:            "tags of any type",
        directories:  "directory nodes on item's path",
      }

      kv_tags
      |> Map.merge(kv_refs) #K - fold in meta.ref
      |> Map.merge(kv_harv) #K - fold in harvested
    else
      kv_tags
    end
  end

  # Get a map of information on typed tags (kv).  If called without `inbt_map`,
  # it gets a copy on its own.  (`get_kv_info/1` is currently unused.)

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

  @spec get_kv_list(map) :: [tuple]

  defp get_kv_list(inp_map) do
  #
  # Get a list of typed tag tuples.
  # (Tally the number of times a tag value is used for a given type.)

    inp_map                         # %{ "<type>:..." => #MapSet<[...]>, ... }
    |> keyss()                      # [ "<type>:...", "...", ... ]
    |> get_typed()                  # [ "<type>:...", ... ]
    |> get_tuples(inp_map)          # [ { :<type>, "<tag>", <cnt> }, ... ]
  end

  @spec get_kv_map([ String.t ]) :: map

  defp get_kv_map(kv_list) do
  #
  # Get a two-level map of counts by type and tag.
  # (Tally the number of times each tag value is used for each type.)

    reduce_fn = fn {tag_type, tag_val, count}, acc ->
    #
    # Generate the two-level map.

      update_fn   = fn old_val -> Map.put(old_val, tag_val, count) end
      #
      # Fold a typed tag into the map.

      initial     = %{ tag_val => count } # Start map with untyped tag.
      Map.update(acc, tag_type, initial, update_fn)
    end

    kv_list
    |> Enum.reduce(%{}, reduce_fn)
  end

  @spec get_tuples([s], map) :: [{atom, s, integer}] when s: String.t

  defp get_tuples(tags, tag_map) do
  #
  # Look up a list of tags in `tag_map`.  Return a descriptive list of tuples.

    tuple_fn  = fn key ->
    #
    # Return a tuple containing the type atom, tag value, and usage count.

      [tag_type, tag_val] = String.split(key, ":")
      type_atom   = String.to_atom(tag_type)
      count       = MapSet.size(tag_map[key])

      {type_atom, tag_val, count}
    end

    Enum.map(tags, tuple_fn)
  end

  @spec get_typed( [ s ] ) :: [ s ] when s: String.t

  defp get_typed(input) do
  #
  # Retain tags with types (i.e., strings that contain a colon.

    filter_fn = fn tag -> String.contains?(tag, ":") end
    #
    # Return true if the tag is typed.

    Enum.filter(input, filter_fn)
  end

end
