# _info_toml_t.ex

defmodule InfoToml.Types do

  @moduledoc """
  This module defines types that are used in `InfoToml` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  alias Common.Types, as: CT

  @typedoc """
  An `id_num` is an ID number.  Because they are commonly stored in lists,
  and we don't want these to be displayed as charlists, we need to start
  the values at 256.  In practice, we start the values at 1000 to make them
  display nicely (e.g., always at least four digits).

      %{ "features:ray-tracing" => #MapSet<[1042, ...]>, ... }
  """
  #K - This assumes that we'll never need more than 1M values.
  @type id_num  :: 1_000..999_999 


  @typedoc """
  An `id_set` is a MapSet of Integer Item IDs.
  """
  @type id_set :: MapSet.t(id_num)


  # item_map, et al

  @typedoc """
  An `item_map` is a tree of maps, with strings at the leaves.
  """
  @type item_map :: %{ CT.map_key => item_part }


  @typedoc """
  The `item_maybe` type allows for missing item data (e.g., in pipelines).
  """
  @type item_maybe :: item_map | nil


  @typedoc """
  The `item_part` type implements the `item_map` tree structure.
  """
  @type item_part :: %{ CT.map_key => item_part | st } #R


  @typedoc """
  An `item_path` is a path list (as used by `get_in/2`) for items.
  """
  @type item_path :: [atom]


  @typedoc """
  An `item_tuple` is a tuple that describes an item:
  
      {<path>, <title>, <precis>}
  """
  @type item_tuple :: {st, st, st}


  @typedoc """
  An `inbt_map` is a map that indexes MapSets of id_num values by tag.

      %{ "features:ray-tracing" => #MapSet<[1042, ...]>, ... }
  """
  @type inbt_map :: %{ st => MapSet.t(id_num) } #K


  # kv_all, et al

  @typedoc """
  The `kv_all` type contains information on usage of key/value trees.
  """
  @type kv_all ::
    %{
      optional(:kv_info)  => kv_info,
      :tracing            => boolean,
    }


  @typedoc """
  The `kv_cnts` type stores usage counts by tag type.

      kv_cnts:    %{ <type>: <count> }
  """
  @type kv_cnts :: %{ atom  => nni }


  @typedoc """
  The `kv_descs` type stores descriptions by tag type.

      kv_descs: %{ <type>: <desc> }
  """
  @type kv_descs :: %{ atom  => st }


  @typedoc """
  The `kv_info` type contains information on usage of key/value trees.

  This information includes descriptive text, usage counts, etc.

      kv_info:    %{
        kv_cnts:    %{ <key>: <count> },
        kv_descs:   %{ <key>: <desc> },
        kv_list:    [ { <key>, <val>, <cnt> }, ... ],
        kv_map:     %{ <key>: %{ <val> => <cnt> }, ... }
      }
  """
  @type kv_info ::
    %{
      :kv_cnts    => kv_cnts,       # %{ <key>: <count> }
      :kv_descs   => kv_descs,      # %{ <key>: <desc> }
      :kv_list    => [kv_tuple],    # [ { <key>, <val>, <cnt> }, ... ]
      :kv_map     => kv_map,        # %{ <key => %{ <val> => <cnt> } }
    }


  @typedoc """
  The `kv_map` type contains information on usage of key/value trees
  (e.g., counts of types by tags).
  """
  @type kv_map :: %{ atom => %{ st => nni } }

  @typedoc """
  The `kv_tuple` type is used to construct the `kv_list`.

      { <key>, <val>, <cnt> }
  """
  @type kv_tuple :: {atom, st, nni}


  # ndx_map, et al

  @typedoc """
  The keys for `ndx_map` can be atoms, id_nums, or strings.
  """
  @type ndx_key :: id_num | CT.map_key


  @typedoc """
  An `ndx_map` is an inverted index into `toml_map[:items]`.
  """
  @type ndx_map :: %{ atom => %{ ndx_key => MapSet.t(ndx_val) } }


  @typedoc """
  The leaf values for `ndx_map` can be id_nums or strings.
  """
  @type ndx_val :: id_num | st


  # schema_map, et al

  @typedoc """
  A `schema` is like an `item_map`, except that it allows strings
  as top-level values.
  """
  @type schema :: %{ atom => item_part | st }


  @typedoc """
  A `schema_map` is a map of schemas.
  """
  @type schema_map :: %{ atom => schema }


  @typedoc """
  A `toml_map` is a map of `item_map` structures, etc.
  (e.g., loaded from a tree of TOML files)
  """
# @type toml_map :: %{ atom: map } #W
  @type toml_map :: map #W

  # Private types

  @typep nni      :: non_neg_integer
  @typep st       :: String.t

end