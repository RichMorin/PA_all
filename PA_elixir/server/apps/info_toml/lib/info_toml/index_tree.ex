# info_toml/index_tree.ex

defmodule InfoToml.IndexTree do
#
# Public functions
#
#   index/1
#     Create the set of indexes.
#
# Private functions
#
#   get_tag_info/2
#     Get a list of (split and trimmed) tag strings.
#   get_tags_info/1
#     Get a list of { tag_type, tag_strs } tuples from item.
#   put_ndx/4
#     Put id_num into the MapSet specified by ndx_type and tag_val.

  @moduledoc """
  This module creates and manages `ndx`, a set of inverted indexes based
  on `meta.tags` entries in the TOML-based map.

      ndx[:id_num_by_key]   = %{ ".../main.toml"    => 1, ... }
      ndx[:key_by_id_num]   = %{ 1000               => ".../main.toml", ... }
      ndx[:id_nums_by_tag]  = %{ "str", "tag:str"   => [ 1000, ... ], ... }

  Use of `id_num` as an intermediate key is an effort to reduce storage
  and/or comparison processing time.  By starting the index at 1000, we
  prevent IEx from displaying ID lists as strings.
  """

  import Common, only: [ csv_split: 1, keyss: 1 ]

  alias Common.Types, as: CT

  # Public functions

  @doc """
  Create the set of indexes.
  """

  @spec index(map) :: CT.ndx_map

  def index(toml_map) do
    ndx     = %{
      id_num_by_key:    %{},
      key_by_id_num:    %{},
      id_nums_by_tag:   %{},
    }

    item_fn   = fn key, ndx ->
    #
    # Create index entries for a single item.

      item        = get_in(toml_map, [:items, key])
      id_num      = get_in(item, [:meta, :id_num])
      gi_path_1   = [:id_num_by_key, key  ]
      gi_path_2   = [:key_by_id_num, id_num]

      ndx   = ndx
      |> put_in(gi_path_1, id_num)
      |> put_in(gi_path_2, key)

      tags_fn     = fn {tag_key, tag_info}, ndx ->
      #
      # Add all tags from an item to the index.

        tag_fn      = fn tag_val, ndx ->
        #
        # Add typed and typeless tags to the index.

          tks_val   = "#{ tag_key }:#{ tag_val }"

          ndx
          |> put_ndx(:id_nums_by_tag, tag_val, id_num)
          |> put_ndx(:id_nums_by_tag, tks_val, id_num)
        end

        # Process the data from a single tag.
        Enum.reduce(tag_info, ndx, tag_fn)
      end

      # Process the `meta.tags` data from a single item.
      tags_info   = get_tags_info(item)
      Enum.reduce(tags_info, ndx, tags_fn)
    end

    filter_fn   = fn key ->
    #
    # Return true if this is the main file for an item.

      pattern   = ~r{ ^ Areas / .* / main \. toml $ }x
      String.match?(key, pattern)       # "Areas/**/main.toml"
    end

    # Process each item in the map.
    toml_map.items                      # %{ ".../main.toml" => %{...} }
    |> keyss()                          # [ <encountered key>, ... ]
    |> Enum.filter(filter_fn)           # [ <allowable key>, ... ]
    |> Enum.reduce(ndx, item_fn)        # %{ <key> => %{...}, ... }
  end

  # Private functions

  @spec get_tag_info(atom, CT.item_map) :: { atom, [ String.t ] }

  defp get_tag_info(tag_type, item) do
  #
  # Get a list of (split and trimmed) tag strings.

    gi_path   = [:meta, :tags, tag_type]
    tag_strs  = item                    # %{ meta: %{ tags: %{ ? }, ? } }
    |> get_in(gi_path)                  # [ " foo, bar ", ? ]
    |> csv_split                        # [ "foo", "bar", ? ]

    {tag_type, tag_strs}
  end

  @spec get_tags_info(CT.item_map) :: [ {atom, [ String.t ] } ]

  defp get_tags_info(item) do
  #
  # Get a list of { tag_type, tag_strs } tuples from item.

    map_fn  = fn tag_type ->
    #
    # Get all tags for the specified type from this item.

      get_tag_info(tag_type, item)
    end

    gi_path   = [:meta, :tags]
    item                                # %{ meta: %{ tags: %{...}, ...} }
    |> get_in(gi_path)                  # %{ aaa: " foo, bar ", ...}
    |> keyss()                          # [ :aaa, ... ]
    |> Enum.map(map_fn)                 # [ {:aaa, ["foo", "bar"]}, ... ]
  end

  @spec put_ndx(CT.ndx_map, atom, String.t, integer) :: CT.ndx_map

  defp put_ndx(ndx, ndx_type, tag_val, id_num) do
  #
  # Put id_num into the MapSet specified by ndx_type and tag_val.
  # If need be, create a new MapSet.

    gi_path   = [ndx_type, tag_val]
    old_ids   = get_in(ndx, gi_path) || MapSet.new()
    new_ids   = MapSet.put(old_ids, id_num)
    put_in(ndx, gi_path, new_ids)
  end

end
