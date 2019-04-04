defmodule InfoWeb.Server do
#
# Public functions
#
#   get_info/1
#     Return the data structure for a link, given its URL.
#   put_info/2
#     Update the data structure for a link, given its URL and a new value.
#   start_link/0
#     Start up the server Agent.
#
# Private functions
#

  @moduledoc """
  This module implements both the external API (eg, `get_info/1`) and the
  setup ceremony (eg, `start_link/0`) for the OTP server.
  """

  @me __MODULE__

  alias InfoWeb.{Checker}
  use Common,   :common
  use InfoWeb, :common
  use InfoWeb.Types

  # external API

  @doc """
  Return the data structure for a link, given its URL.
  """

  @spec get_info(String.t) :: map | nil

  def get_info(link_url) do
    get_fn = fn link_maps -> link_maps[link_url] end

    Agent.get(@me, get_fn)
  end

  @doc """
  Update the data structure for a link, given its URL and a new value.
  """

  @spec put_info(String.t, map) :: [ String.t ]

  def put_info(link_url, link_map) do
    put_fn = fn link_maps -> Map.put(link_maps, link_url, link_map) end

    Agent.update(@me, put_fn)
  end

  @doc """
  Start up the server Agent.
  """

  @spec start_link() :: {atom, pid | String.t }

  def start_link() do
    Agent.start_link(&first_load/0, name: @me)
  end

  # Private functions

  @spec first_load() :: map

  defp first_load() do
  #
  # Handle initial loading of data.

    %{}   # WIP
  end

end
