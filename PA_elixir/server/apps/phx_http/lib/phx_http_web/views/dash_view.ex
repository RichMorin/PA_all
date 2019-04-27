# views/dash_view.ex

defmodule PhxHttpWeb.DashView do
#
# Public functions
#
#   get_avg_cnts/1
#     Get a Map of the average number of values used for each tag type.
#   get_dup_vals/1
#     Get a Map of duplicate ref or tag values with associates types and counts.
#   get_odd_vals/1
#     Get a List of odd ref or tag values and associated types.
#   get_total_cnts/2
#     Get a Map of the total number of values used for this tag type.

  use PhxHttpWeb, :view

  use Common, :common

  @doc """
  Get a Map of the average number of values used for each tag type, eg:

      %{ miscellany: 0.22, ... }

      iex> acd = get_avg_cnts(42).directories 
      iex> is_float(acd)
      true
  """

  @spec get_avg_cnts(map) :: map #W

  def get_avg_cnts(main_cnt) do

    items       = [ :items ] |> InfoToml.get_part()

    filter_fn   = fn {key, _item} -> String.ends_with?(key, "/main.toml") end

    merge_fn    = fn _k, v1, v2 -> v1 + v2 end

    reduce_fn1  = fn {_key, item}, acc ->

      reduce_fn1a = fn {tag_type, tag_str}, acc ->
        tag_cnt   = tag_str
        |> str_list()
        |> Enum.count()

        Map.put(acc, tag_type, tag_cnt)
      end

      tag_cnts    = item.meta.tags      # %{ <type>: [ "foo", ... ], ... }
      |> Enum.reduce(%{}, reduce_fn1a)  # %{ <type>: <tag_cnt>, ... }

      Map.merge(acc, tag_cnts, merge_fn)
    end

    reduce_fn2  = fn {tag_type, tag_cnt}, acc ->
      avg_cnt   = tag_cnt / main_cnt

      Map.put(acc, tag_type, avg_cnt)        
    end

    items                             # %{ key => %{...}, ... }
    |> Enum.filter(filter_fn)         # %{ key => %{...}, ... }
    |> Enum.reduce(%{}, reduce_fn1)   # %{ <type>: <tag_cnt>, ... }
    |> Enum.reduce(%{}, reduce_fn2)   # %{ <type>: <avg_cnt>, ... }
  end

  @doc """
  Get a Map of duplicate tag values with associated types and counts, eg:

      %{ <tag>        => "<type>   (<cnt>), ..." }
      %{ "trade show" => "produces (1),     roles (1)", ...}

      iex> kv_list  = [ {:foo, "baz", 1}, {:bar, "baz", 2} ]
      iex> dup_vals = get_dup_vals(kv_list)
      iex> dup_vals["baz"]
      "bar (2), foo (1)"
      iex> dup_vals["no_such"]
      nil
  """

  @spec get_dup_vals(map) :: map #W

  def get_dup_vals(kv_list) do

    punt_list   = ~w(f_authors f_editors)a

    punt_fn     = fn {type, _cnt}   -> Enum.member?(punt_list, type) end
    
    filter_fn   = fn {_tag, tuples} ->
      cnt_keep  = tuples |> Enum.reject(punt_fn) |> Enum.count()
      cnt_punt  = tuples |> Enum.filter(punt_fn) |> Enum.count()
      
      ( cnt_keep > 1 ) ||
      ( cnt_keep * cnt_punt > 0 )
    end

    reduce_fn1  = fn {type, tag, cnt}, acc ->
      tuple       = {type, cnt}
      initial     = [ tuple ]
      update_fn   = fn old_val -> [ tuple | old_val ] end

      Map.update(acc, tag, initial, update_fn)
    end

    map_fn1     = fn {type, cnt}  -> "#{ type } (#{ cnt })" end
    reduce_fn2  = fn {tag, type_str}, acc -> Map.put(acc, tag, type_str) end

    sort_fn1    = fn {tag, _list} -> tag  end
    sort_fn2    = fn {type, _cnt} -> type end

    map_fn2     = fn {tag, type_list} ->
      type_str = type_list
      |> Enum.sort_by(sort_fn2)
      |> Enum.map(map_fn1)
      |> Enum.join(", ")

      {tag, type_str}
    end

    kv_list                           # [ {:miscellany, "CLI", 1}, ...]
    |> Enum.reduce(%{}, reduce_fn1)   # %{ <tag> => [ {<type>, <cnt>} ] } 
    |> Enum.filter(filter_fn)         # [ { <tag>, [ {<type>, <cnt>} ] } ]
    |> Enum.sort_by(sort_fn1)         # ditto, but sorted
    |> Enum.map(map_fn2)              # [ {<tag>, "<type> (<cnt>), ..."} ]    
    |> Enum.reduce(%{}, reduce_fn2)   # %{ <tag> => "<type> (<cnt>), ..." } 
#   |> ii("get_dup_vals")
  end

  @doc """
  Get a List of odd tag values and associated tag types.
  That is, values which contain characters other than:

  - alphanumeric characters (A-Z, a-z, 0-9)
  - plus (+), minus (-), underscore (_)
  - parentheses (i.e., round brackets)
  - period (.), sharp sign (#), slash (/)

      iex> kv_list  = [ {:foo, "foo", 1}, {:foo, "bar", 2} ]
      iex> get_odd_vals(kv_list)
      []

      iex> kv_list  = [ {:foo, "foo", 1}, {:bar, "bar?", 2} ]
      iex> get_odd_vals(kv_list)
      [{"bar?", :bar, 999}]
  """

  @spec get_odd_vals(map) :: list #W

  def get_odd_vals(kv_list) do
    odd_patt    = ~r{[^-+_\. (/#)A-Za-z0-9]}
    filter_fn   = fn {_type, tag, _cnt} -> tag =~ odd_patt end

    map_fn      = fn {type, tag, _cnt}  ->
      keys      = InfoToml.keys_by_tag(tag)

      if Enum.empty?(keys) do
        {tag, type, 999} #K
      else
        {tag, type, hd(keys)}
      end
    end

    sort_fn     = fn {tag, _type, _key} -> tag end

    kv_list                           # [ {:miscellany, "CLI", 1}, ...]
    |> Enum.filter(filter_fn)         # ditto, but filtered
    |> Enum.map(map_fn)               # [ {"CLI", :miscellany}, ... ]    
    |> Enum.sort_by(sort_fn)          # ditto, but sorted
#   |> ii("get_odd_tags")
  end

  @doc """
  Get a Map of the total number of values used for this tag type.

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

  @spec get_total_cnts(list, map) :: map #W

  def get_total_cnts(tag_types, kv_map) do
    reduce_fn2  = fn tag_val, acc -> MapSet.put(acc, tag_val) end

    reduce_fn1  = fn tag_type, acc ->
      total_cnt   = kv_map[tag_type]
      |> Map.keys()
      |> Enum.reduce(%MapSet{}, reduce_fn2)
      |> MapSet.to_list()
      |> Enum.count()

      Map.put(acc, tag_type, total_cnt)
    end

    tag_types |> Enum.reduce(%{}, reduce_fn1)
  end

end
