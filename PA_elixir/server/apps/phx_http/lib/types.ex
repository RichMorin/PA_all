# phx_http/lib/types.ex

defmodule PhxHttp.Types do

  @moduledoc """
  This module defines types for use in `PhxHttp` and `PhxHttpWeb`.
  It doesn't contain any functions, just attributes.
  """

  @typedoc """
  An `addr_part` is a Map of Strings.
  """

  @type addr_part   :: %{atom => String.t}

  @typedoc """
  An `address` is a Map of Maps of Strings.
  """

  @type address     :: %{atom => addr_part}

  @typedoc """
  A `Plug.Conn` is a Struct with a bazillion entries.
  """

  @type conn        :: Plug.Conn.t

  @typedoc """
  An `id_set` is a MapSet of Integer Item IDs.
  """

  @type id_set      :: MapSet.t(integer)

  @typedoc """
  A `params` Map is populated by Phoenix from a GET or POST request.
  """

  @type params      :: %{ String.t => String.t }

  @typedoc """
  An `s_pair` (String pair) is a two-string Tuple.
  """

  @type s_pair      :: {String.t, String.t}

  @typedoc """
  `safe_html` is HTML that is guaranteed to be safe to emit.
  """

  @type safe_html   :: {:safe, iolist | String.t} | String.t


  @typedoc """
  A `tag_info` Map contains Maps of strings to Integers.
  """

  @type tag_info    :: %{ String.t => %{ String.t => integer } }

  @typedoc """
  A `tag_map` is a Map containing MapSet instances.
  """

  @type tag_map     :: %{ (atom | String.t) => MapSet.t(tag_val) }

  @typedoc """
  A `tag_set` is a list of `type:tag` strings.
  """

  @type tag_set     :: [ String.t ]

  @typedoc """
  `tag_sets` is a Map of `tag_set` values by ID string (e.g., "a").
  """

  @type tag_sets    :: %{ String.t => tag_set }

  @typep tag_val     :: integer | String.t

end
