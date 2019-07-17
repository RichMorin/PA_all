# _phx_http_t.ex

defmodule PhxHttp.Types do

  alias InfoToml.Types, as: ITT

  @moduledoc """
  This module defines types for use in `PhxHttp` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  @typedoc """
  An `addr_part` is a Map of Strings.
  """
  @type addr_part :: %{ atom => st }


  @typedoc """
  An `address` is a Map of Maps of Strings.
  """
  @type address :: %{ atom => addr_part }


  @typedoc """
  A `gi_pair` is a tuple, containing a `gi_path` (i.e., a `get_in`-style path),
  coupled with a value.
  """
  @type gi_pair :: { [atom], st }


  @typedoc """
  A `params` Map is populated by Phoenix from a GET or POST request.
  """
  @type params :: %{ st => st } | [] #W - Search.show/2 needed this


  @typedoc """
  A `pkg_info` map contains build information on a package:
  
      %{
        main: %{
          key:      "Areas/Catalog/Software/Alacritty/main.toml",
          precis:   "a cross-platform, GPU-accelerated terminal emulator",
          title:    "Alacritty"
        },
        make: %{
          arch: true,
          debian: true,
          main: true,
          name: "Alacritty",
          other: false
        }
      }
  """
  @type pkg_info ::
    %{
      main: %{
        key:      st,
        precis:   st,
        title:    st
      },
      make: %{ atom => any }
    }


  @typedoc """
  A `pkg_map` contains build information on multiple packages:
  
      %{
        "Alacritty" => %{
          main: %{ ... },
          make: %{ ... }
        }, ...
      }
  """
  @type pkg_map :: %{ st => pkg_info }


  @typedoc """
  An `s_pair` (String pair) is a two-string Tuple.
  """
  @type s_pair :: {st, st}


  @typedoc """
  `safe_html` is HTML that is guaranteed to be safe to emit.
  """
  @type safe_html :: {:safe, iolist | st} | st


  @typedoc """
  A `tag_info` Map contains Maps of strings to id_nums.
  """
  @type tag_info :: %{ st => %{ st => ITT.id_num } }


  @typedoc """
  A `tag_map` is a Map containing MapSet instances.
  """
  @type tag_map :: %{ (atom | st) => MapSet.t(tag_val) }


  @typedoc """
  A `tag_set` is a list of `type:tag` strings.
  """
  @type tag_set :: [st]


  @typedoc """
  `tag_sets` is a Map of `tag_set` values by ID string (e.g., "a").
  """
  @type tag_sets :: %{ st => tag_set }

  # Private types

# @typep nni      :: non_neg_integer
  @typep st       :: String.t
  @typep tag_val  :: integer | st

end
