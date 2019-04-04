# .../lib/types.ex

defmodule InfoWeb.Types do

  @moduledoc """
  This module defines types for use throughout `InfoWeb`.  It doesn't contain
  any functions, just `@type` attributes.
  """

  defmacro __using__(_) do
    quote do

      @type map_key     :: atom | String.t
    end
  end

end
