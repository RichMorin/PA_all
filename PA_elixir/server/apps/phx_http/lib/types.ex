# phx_http/lib/types.ex

defmodule PhxHttp.Types do

  @moduledoc """
  This module defines types for use throughout `PhxHttp` and `PhxHttpWeb`.
  It doesn't contain any functions, just `@type` attributes.
  """

# @spec - ToDo

  defmacro __using__(_) do
    quote do

      @doc """
      An `addr_part` is a Map of Strings.
      """

      @type addr_part   :: %{atom => String.t}

      @doc """
      An `address` is a Map of Maps of Strings.
      """

      @type address     :: %{atom => addr_part}

      @doc """
      A `Plug.Conn` is a Struct with a bazillion entries.
      """

      @type conn        :: Plug.Conn.t

      @doc """
      An `id_set` is a MapSet of Integer Item IDs.
      """

      @type id_set      :: MapSet.t(integer)

      @doc """
      A `params` Map is populated by Phoenix from a GET or POST request.
      """

      @type params      :: %{ String.t => String.t }

      @doc """
      An `s_pair` (String pair) is a two-string Tuple.
      """

      @type s_pair      :: {String.t, String.t}

      @doc """
      `safe_html` is HTML that is guaranteed to be safe to emit.
      """

      @type safe_html   :: {:safe, iolist | String.t} | String.t


      @doc """
      A `tag_info` Map contains Maps of Strings to Integers.
      """

      @type tag_info    :: %{ String.t => %{ String.t => integer } }

      @doc """
      A `tag_map` is a Map containing MapSet instances.
      """

      @type tag_map     :: %{ (atom | String.t) => MapSet.t(tag_val) }

      @doc """
      A `tag_set` is a list of `type:tag` strings.
      """

      @type tag_set     :: [ String.t ]

      @doc """
      `tag_sets` is a Map of `tag_set` values by ID string (eg, "a").
      """

      @type tag_sets    :: %{ String.t => tag_set }

      @typep tag_val     :: integer | String.t
    end
  end

end
