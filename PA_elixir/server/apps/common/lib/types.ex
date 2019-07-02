# common/lib/types.ex

defmodule Common.Types do

  @moduledoc """
  This module defines types for use throughout Pete's Alley.
  It doesn't contain any functions, just attributes.
  """

  @typedoc """
  An `item_map` is a tree of maps, with strings at the leaves.
  """

  @type item_map    :: %{ map_key => item_part }

  @typedoc """
  The `item_maybe` type allows for missing item data (e.g., in pipelines).
  """

  @type item_maybe  :: item_map | nil

  @typedoc """
  The `item_part` type implements the `item_map` tree structure.
  """

  @type item_part   :: %{ map_key => item_part | String.t } #R

  @typedoc """
  An `item_path` is a path list (as used by `get_in/2`) for items.
  """

  @type item_path   :: [ atom ]

  @typedoc """
  With very few exceptions, we use atoms and strings as map keys.
  The `map_key` type formalizes this practice. 
  """

  @type map_key     :: atom | String.t

  @typedoc """
  The keys for `ndx_map` can be atoms, integers, or strings.
  """

  @type ndx_key     :: integer | map_key

  @typedoc """
  An `ndx_map` is an inverted index into `toml_map[:items]`.
  """

  @type ndx_map     :: %{ atom => %{ ndx_key => MapSet.t(ndx_val) } }

  @typedoc """
  The leaf values for `ndx_map` can be integers or strings.
  """

  @type ndx_val     :: integer | String.t

  @typedoc """
  A schema is like an `item_map`, except that it allows strings
  as top-level values.
  """

  @type schema      :: %{ atom => item_part | String.t }

  @typedoc """
  A `schema_map` is a map of schemas.
  """

  @type schema_map  :: %{ atom => schema }

  @typedoc """
  A `toml_map` is a map of `item_map` structures.
  (e.g., loaded from a tree of TOML files)
  """

  @type toml_map    :: %{ String.t => item_map }

end
