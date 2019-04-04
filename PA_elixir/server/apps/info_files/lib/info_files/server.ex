defmodule InfoFiles.Server do

  @moduledoc """
  This module is only a stub.
  """

  @me __MODULE__

  # setup ceremony

  @spec start_link() :: {atom, pid | String.t }

  def start_link() do
    Agent.start_link(&first_load/0, name: @me)
  end

  @spec first_load() :: map

  defp first_load(), do: %{}
  #
  # We're not using this Agent at the moment, but we may RSN ...
end
