# _common_t.ex

defmodule Common.Types do

  @moduledoc """
  This module defines types for use throughout Pete's Alley.
  It doesn't contain any functions, just attributes.
  """

  @typedoc """
  With very few exceptions, we use atoms and strings as map keys.
  The `map_key` type formalizes this practice. 
  """
  @type map_key :: atom | st


  # Private types

  @typep st       :: String.t

end
