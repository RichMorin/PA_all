# common/lib/types.ex

defmodule Common.Types do

  @moduledoc """
  This module defines types for use throughout Pete's Alley.  It doesn't
  contain any functions, just `@type` attributes.
  """

# @spec - ToDo

  defmacro __using__(_) do
    quote do

      @doc """
      With very few exceptions, we use Atoms and Strings as Map keys.
      The `map_key` type formalizes this practice. 
      """

      @type map_key     :: atom | String.t

      @doc """
      An `item_map` is a tree of Maps, with Strings at the leaves.
      """

      @type item_map    :: %{ map_key => item_part }

      @doc """
      The `item_maybe` type allows for missing item data (e.g., in pipelines).
      """

      @type item_maybe  :: item_map | nil

      @doc """
      The `item_part` type implements the `item_map` tree structure.
      """

      @type item_part   :: %{ map_key => item_part | String.t } #R

      @doc """
      An `item_path` is a path list (as used by `get_in/2`) for items.
      """

      @type item_path   :: [ atom ]

      @doc """
      The keys for `ndx_map` can be atoms, integers, or strings.
      """

      @type ndx_key     :: integer | map_key

      @doc """
      An `ndx_map` is an inverted index into `toml_map[:items]`.
      """

      @type ndx_map     :: %{ atom => %{ ndx_key => MapSet.t(ndx_val) } }

      @doc """
      The leaf values for `ndx_map` can be integers or strings.
      """

      @type ndx_val     :: integer | String.t

      @doc """
      A schema is like an `item_map`, except that it allows Strings
      as top-level values.
      """

      @type schema      :: %{ atom => item_part | String.t }

      @doc """
      A `schema_map` is a Map of schemas.
      """

      @type schema_map  :: %{ atom => schema }

      @doc """
      A `toml_map` is a Map of `item_map` structures.
      (e.g., loaded from a tree of TOML files).
      """

      @type toml_map    :: %{ String.t => item_map }
    end
  end

end
