# info_web/lib/types.ex

defmodule InfoWeb.Types do

  @moduledoc """
  This module defines types for use throughout `InfoWeb`.  It doesn't contain
  any functions, just `@type` attributes.
  """

# @spec - ToDo

  defmacro __using__(_) do
    quote do

      @doc """
      With very few exceptions, we use Atoms and Strings as Map keys.
      The `map_key` type formalizes this practice. 
      """

      @type map_key     :: atom | String.t
    end
  end

end
