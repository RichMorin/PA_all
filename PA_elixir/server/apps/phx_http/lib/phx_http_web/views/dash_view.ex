# phx_http_web/views/dash_view.ex

defmodule PhxHttpWeb.DashView do
#
# Public functions
#
#   get_avg_cnts/1
#     Get a map of the average number of values used for each tag type.
#   get_dup_vals/1
#     Get a map of duplicate ref or tag values with associates types and counts.
#   get_odd_vals/1
#     Get a list of odd ref or tag values and associated types.
#   get_total_cnts/2
#     Get a map of the total number of values used for this tag type.
#
# Private functions
#
#   get_dup_vals_h/1
#     Do the first half of the work for get_dup_vals/1.

  @moduledoc """
  This module supports rendering of the `dash` templates.
  """

  use PhxHttpWeb, :view

  # Public functions

  @doc """
  Get a map of the average number of values used for each tag type, e.g.:

      %{ directories: 0.22, ... }

      iex> acd = get_avg_cnts(42).directories 
      iex> is_float(acd)
      true
  """

  @spec get_avg_cnts(map) :: map #W - map

  def get_avg_cnts(main_cnt) do

    items       = [ :items ] |> InfoToml.get_part()

    main_fn     = fn {key, _item} -> String.ends_with?(key, "/main.toml") end
    #
    # Return true if this is the main file for an item.

    sum_fn      = fn _tag, cnt_1, cnt_2 -> cnt_1 + cnt_2 end
    #
    # Sum a pair of tag usage counts, ignoring type.

    count_fn  = fn {_key, item}, acc ->
    #
    # Build a map of tag type usage counts.

      type_fn   = fn {tag_type, tag_str}, acc ->
      #
      # Tally tag usage by type.

        tag_cnt   = tag_str
        |> csv_split()
        |> Enum.count()

        Map.put(acc, tag_type, tag_cnt)
      end

      tag_cnts    = item.meta.tags      # %{ <type>: [ "foo", ... ], ... }
      |> Enum.reduce(%{}, type_fn)      # %{ <type>: <tag_cnt>, ... }

      Map.merge(acc, tag_cnts, sum_fn)
    end

    avg_fn      = fn {tag_type, tag_cnt}, acc ->
    #
    # Build a map of tag count averages.

      avg_cnt   = tag_cnt / main_cnt
      Map.put(acc, tag_type, avg_cnt)        
    end

    items                             # %{ key => %{...}, ... }
    |> Enum.filter(main_fn)           # same, but only main files
    |> Enum.reduce(%{}, count_fn)     # %{ <type>: <tag_cnt>, ... }
    |> Enum.reduce(%{}, avg_fn)       # %{ <type>: <avg_cnt>, ... }
  end

  @doc """
  Get a map of duplicate tag values with associated types and counts, e.g.:

      %{ <tag>        => "<type>   (<cnt>), ..." }
      %{ "trade show" => "produces (1),     roles (1)", ...}

      iex> kv_list  = [ {:foo, "baz", 1}, {:bar, "baz", 2} ]
      iex> dup_vals = get_dup_vals(kv_list)
      iex> dup_vals["baz"]
      "bar (2), foo (1)"
      iex> dup_vals["no_such"]
      nil
  """

  @spec get_dup_vals( [tuple] ) :: map #W - map, tuple

  def get_dup_vals(kv_list) do

    fmt_fn      = fn {type, cnt}  -> "#{ type } (#{ cnt })" end
    #
    # Format the type and count for output.

    map_fn      = fn {tag, type_list} ->
    #
    # Generate a comma-separated list.

      type_str = type_list
      |> sort_by_elem(0)
      |> Enum.map(fmt_fn)
      |> Enum.join(", ")

      {tag, type_str}
    end

    reduce_fn   = fn {tag, type_str}, acc -> Map.put(acc, tag, type_str) end
    #
    # Generate a map of formatted type counts, by tag.

    kv_list                           # [ {:miscellany, "CLI", 1}, ...]
    |> get_dup_vals_h()               # [ { <tag>, [ {<type>, <cnt>} ] } ]
    |> Enum.map(map_fn)               # [ {<tag>, "<type> (<cnt>), ..."} ]    
    |> Enum.reduce(%{}, reduce_fn)    # %{ <tag> => "<type> (<cnt>), ..." } 
#   |> ii("get_dup_vals")
  end

  @doc """
  Get a list of odd tag values and associated tag types.
  That is, values which contain characters other than:

  - alphanumeric characters (A-Z, a-z, 0-9)
  - plus (+), minus (-), underscore (_)
  - parentheses (i.e., round brackets)
  - period (.), sharp sign (#), slash (/)

  <!-- -->
      iex> kv_list  = [ {:foo, "foo", 1}, {:foo, "bar", 2} ]
      iex> get_odd_vals(kv_list)
      []

      iex> kv_list  = [ {:foo, "foo", 1}, {:bar, "bar?", 2} ]
      iex> get_odd_vals(kv_list)
      [ {"bar?", :bar, 999} ]
  """

  @spec get_odd_vals(map) :: list #W - list, map

  def get_odd_vals(kv_list) do

    odd_tag_fn   = fn {_type, tag, _cnt} ->
    #
    # Return true if this tag value is "odd".

      odd_patt    = ~r{[^-+_\. (/#)A-Za-z0-9]}
      tag =~ odd_patt
    end

    tuple_fn   = fn {type, tag, _cnt} ->
    #
    # Build a list of tuples.

      keys      = InfoToml.keys_by_tag(tag)

      if Enum.empty?(keys) do
        {tag, type, 999} #K
      else
        {tag, type, hd(keys)}
      end
    end

    kv_list                           # [ {:miscellany, "CLI", 1}, ...]
    |> Enum.filter(odd_tag_fn)        # retain only odd tag values
    |> Enum.map(tuple_fn)             # [ {"CLI", :miscellany}, ... ]    
    |> sort_by_elem(0)                # ditto, but sorted by tag
#   |> ii("get_odd_tags")
  end

  @doc """
  Get a map of the total number of values used for this tag type.

      iex> tag_types = [ :foo ]
      iex> kv_map = %{ foo: %{ "bar" => 42 } }
      iex> get_total_cnts(tag_types, kv_map)
      %{ foo: 1 }

      iex> tag_types = [ :foo ]
      iex> kv_map = %{ foo: %{ "bar" => 42, "baz" => 43 } }
      iex> get_total_cnts(tag_types, kv_map)
      %{ foo: 2 }

      iex> tag_types = [ :foo, :bar ]
      iex> kv_map = %{ foo: %{ "bar" => 42 }, bar: %{ "baz" => 43 } }
      iex> get_total_cnts(tag_types, kv_map)
      %{foo: 1, bar: 1}
  """

  @spec get_total_cnts(list, map) :: map #W - list, map

  def get_total_cnts(tag_types, kv_map) do

    mapset_fn = fn tag_val, acc -> MapSet.put(acc, tag_val) end
    #
    # Build a MapSet of tag values.

    count_fn  = fn tag_type, acc ->
    #
    # Build a map of tag usage counts.

      total_cnt   = kv_map[tag_type]
      |> Map.keys()
      |> Enum.reduce(%MapSet{}, mapset_fn)
      |> MapSet.to_list()
      |> Enum.count()

      Map.put(acc, tag_type, total_cnt)
    end

    tag_types |> Enum.reduce(%{}, count_fn)
  end

  # Private functions

  @spec get_dup_vals_h(tl) :: tl
    when tl: [tuple] #W - tuple

  defp get_dup_vals_h(tuples) do
  #
  # Do the first half of the work for get_dup_vals/1.

    punt_fn     = fn {type, _cnt} ->
    #
    # Return true if this tag type is in the punt list.

      punt_list   = ~w(f_authors f_editors)a
      Enum.member?(punt_list, type)
    end
    
    dup_fn    = fn {_tag, tuples} ->
    #
    # Return true if this tag value is a duplicate across types.

      cnt_keep  = tuples |> Enum.reject(punt_fn) |> Enum.count()
      cnt_punt  = tuples |> Enum.filter(punt_fn) |> Enum.count()
      
      ( cnt_keep > 1 ) || ( cnt_keep * cnt_punt > 0 )
    end

    reduce_fn   = fn {type, tag, cnt}, acc ->
    #
    # Generate a map of {<type>, <cnt>}, indexed by <tag>.

      tuple       = {type, cnt}
      initial     = [ tuple ]

      update_fn   = fn old_val -> [ tuple | old_val ] end
      #
      # Add a tuple to the map.

      Map.update(acc, tag, initial, update_fn)
    end

    tuples                            # [ {:miscellany, "CLI", 1}, ...]
    |> Enum.reduce(%{}, reduce_fn)    # %{ <tag> => [ {<type>, <cnt>} ] } 
    |> Enum.filter(dup_fn)            # [ { <tag>, [ {<type>, <cnt>} ] } ]
    |> sort_by_elem(0)                # ditto, but sorted by tag value
  end

end
