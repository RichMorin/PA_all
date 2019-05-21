# phx_http/lib/types.ex

defmodule PhxHttp.Types do

  @moduledoc """
  This module defines types for use throughout `PhxHttp` and `PhxHttpWeb`.
  It doesn't contain any functions, just `@type` attributes.
  """

# @spec - ToDo

  defmacro __using__(_) do
    quote do
      # `address` is a map of maps of strings.

      @type addr_sec    :: %{atom => String.t}
      @type address     :: %{atom => addr_sec}

      # `Plug.Conn` is a struct with a bazillion entries.

      @type conn        :: Plug.Conn.t

      # `id_sets` is a list containing `MapSet` instances.

      @type id_reduce   :: (id_sets, id_set -> id_set)
      @type id_sets     :: [ id_set ]
      @type id_set      :: MapSet.t(integer)

      # A map key is (generally) an atom or a string.

      #K I'd prefer to bring in `map_key` from `Common.Types`.)

      @type map_key_ph  :: atom | String.t

      # `params` is a map populated by a GET or POST request.

      @type params      :: %{ String.t => String.t }

      # `safe_html` is guaranteed to be safe to emit.

      @type safe_html   :: {:safe, iolist | String.t} | String.t

      # `tag_map` is a map containing `MapSet` instances.

      @type tag_info    :: %{ String.t => %{ String.t => integer } }
      @type tag_map     :: %{ map_key_ph => MapSet.t(tag_val) }
      @type tag_val     :: integer | String.t

      # A `tag_set` is a list of `type:tag` strings.
      # `tag_sets` is a map of `tag_set` values by ID string (eg, "a").

      @type s_pair      :: {String.t, String.t}
      @type s_pairs     :: [ s_pair ]
      @type tag_set     :: [ String.t ]
      @type tag_sets    :: %{ String.t => tag_set }
    end
  end

end
