# _info_files_t.ex

defmodule InfoFiles.Types do

  @moduledoc """
  This module defines types for use in `InfoFiles` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  alias Common.Types, as: CT

  @typedoc """
  A `cnt_map` is a map of counts.

      %{
        char:  2000,
        file:  2,
        func:  20,
        line:  200
      }
  """
  @type cnt_map :: %{ atom => nni }


  @typedoc """
  An `info_map` is a map that holds collected information.
  """
  @type info_map :: %{ CT.map_key => any } #W - loose


  # Private types

  @typep nni      :: non_neg_integer
# @typep st       :: String.t

end
