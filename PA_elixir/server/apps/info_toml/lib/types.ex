# .../lib/types.ex

defmodule InfoToml.Types do

  @moduledoc """
  This module defines types for use throughout `InfoToml`.  It doesn't contain
  any functions, just `@type` attributes.
  """

  defmacro __using__(_) do
    quote do

      @type map_key     :: atom | String.t

      # An item is a tree of maps, with strings at the leaves.

      @type item_map    :: %{ map_key => item_part }
      @type item_maybe  :: item_map | nil
      @type item_part   :: %{ map_key => item_part | String.t }

      # Define path lists, as used by `get_in/2`, for items.

      @type item_path   :: [ atom ]
      @type item_paths  :: [ item_path ]

      # An ndx_map is an inverted index into `toml_map[:items]`.

      @type ndx_key     :: integer | map_key
      @type ndx_map     :: %{ atom => ndx_sec }
      @type ndx_sec     :: %{ ndx_key => ndx_vals }
      @type ndx_val     :: integer | String.t
      @type ndx_vals    :: MapSet.t(ndx_val)

      # A result is a tuple.

      @type result      :: {String.t, String.t, String.t}
      @type results     :: [ result ]

      # A schema is like an item, but allows strings as top-level-values.

      @type schema      :: %{ atom => item_part | String.t }
      @type schemas     :: %{ atom => schema }

      # A toml_map is a map of items (loaded from a tree of TOML files).

      @type toml_map    :: %{ String.t => item_map }
      @type toml_maybe  :: toml_map | nil
    end
  end

end
