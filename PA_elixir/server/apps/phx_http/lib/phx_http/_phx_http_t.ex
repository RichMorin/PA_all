# _phx_http_t.ex

defmodule PhxHttp.Types do

  alias Common.Types,   as: CT
  alias InfoToml.Types, as: ITT

  @moduledoc """
  This module defines types for use in `PhxHttp` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  @typedoc """
  An `addr_part` is part of an `address`.
  """
  @type addr_part :: %{ atom => st }


  @typedoc """
  An `err_list` is a List of Tuples that describe errors, e.g.:

      [ {:warning, 105, "Closing unclosed backquotes ` at end of input"} ]
  """
  @type err_list :: [ {atom, nni, st} ]


  @typedoc """
  An `address` is a Map of Maps of Strings, containing address information.
  """
  @type address :: %{ atom => addr_part }


  @typedoc """
  A `gi_pair` is a tuple, containing a `gi_path` (i.e., a `get_in`-style path),
  coupled with a (string) value.
  """
  @type gi_pair :: { CT.gi_path, st }


  @typedoc """
  A `params` Map is populated by Phoenix from a GET or POST request.
  """
  #!K - The [] possibility is needed by Search.show/2.
  @type params :: %{ st => st } | []


  @typedoc """
   A `path_map` contains item paths, indexed by `id_num`.
   """
  @type path_map :: %{ ITT.id_num => st }


  @typedoc """
  A `pkg_info` map contains build information for a single package:
  
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
      make: %{ atom => boolean | st }
    }


  @typedoc """
  A `pkg_map` contains build information for multiple packages:
  
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
  `tag_sets` is a Map of lists of `<type>:<tag>` strings,
  indexed by ID string.  For example:
  
      %{"a" => ["f_authors:Rich_Morin"]}
  """
  @type tag_sets :: %{ st => [st] }


  # Private types

  @typep nni      :: non_neg_integer
  @typep st       :: String.t

end
