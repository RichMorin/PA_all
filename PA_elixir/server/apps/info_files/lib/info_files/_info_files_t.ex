# _info_files_t.ex

defmodule InfoFiles.Types do

  @moduledoc """
  This module defines types for use in `InfoFiles` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  alias Common.Types, as: CT

  @typedoc """
  A `cnt_map` is a map of counts, as used by various dashboards.

      %{
        char:  2000,
        file:  2,
        func:  20,
        line:  200
      }
  """
  @type cnt_map :: %{ atom => nni }


  @typedoc """
  An `info_map` is a map that holds miscellaneous information
  (e.g., on a tree of code):

      %{
        cnts_by_app:    %{ "<app>"  => %{...}, ... },
        cnts_by_ext:    %{ "<ext>"  => %{...}, ... },
        cnts_by_path:   %{ "<path>" => %{...}, ... },
        file_paths:     [ "<path>", ... ],
        tree_base:      "<tree_base>",
        tree_bases:     [ "<base>", ... ],
        tracing:        false,
      }
  """
  @type info_map :: %{ CT.map_key => bool | cnt_map | st | [st] }


  # Private types

  @typep nni      :: non_neg_integer
  @typep st       :: String.t

end
