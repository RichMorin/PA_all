# info_toml/server.ex

defmodule InfoToml.Server do
#
# Public functions
#
#   reload/0
#     Reload and re-index the TOML file tree.
#   start_link/0
#     Start up the server Agent.
#
# Private functions
#
#   first_load/0
#     Handle initial loading of data.
#   toml_load/1
#     Load and index a set of TOML files.

  @moduledoc """
  This module implements maintenance tasks (eg, `start_link/0`, `build_map/0`)\
  for the OTP server.
  """

  @me __MODULE__

  use Common.Types

  import Common, warn: false, only: [ ii: 2, keyss: 1]

  alias InfoToml.{CheckTree, IndexTree, LoadTree, Schemer}

  # Public functions

  @doc """
  Reload and re-index the TOML file tree.
  """

  @spec reload() :: {atom, String.t}

  def reload() do

    old_map   = Agent.get(@me, &(&1) )

    {status, messages, toml_map} = toml_load(old_map)
    msg_str   = "(#{ Enum.join(messages, ", ") })"

    update_fn = fn _ignore -> toml_map end
    #
    # Ignore the current TOML map; install the new one.

    case status do
      :ok ->
        Agent.update(@me, update_fn)
        {:info,  "Updated without problems."}
      :warning ->
        Agent.update(@me, update_fn)
        {:error, "Updated with warnings #{ msg_str }."}
      :error ->
        {:error, "Update failed #{ msg_str }."}
    end
  end

  @doc """
  Start up the server Agent.
  """

  @spec start_link() :: {atom, pid | String.t }

  def start_link() do
    Agent.start_link(&first_load/0, name: @me)
  end

  # Private functions

  @spec first_load() :: map #W

  defp first_load() do
  #
  # Handle initial loading of data.

    {status, messages, toml_map} = toml_load()

    case status do
      :ok   -> toml_map
      _     ->
        IO.puts ">>> Errors in InfoToml.first_load/0:\n"
        IO.puts Enum.join(messages, ", /n")
        IO.puts ""
        exit("Exiting due to global TOML errors.")
        toml_map       #K - Can we cause PhxHttp not to start up?
    end
  end

  @spec toml_load(map | nil) :: {atom, [ String.t ], map}

  defp toml_load(old_map \\ nil) do
  #
  # Load and index a set of TOML files.
  # Used by both `first_load/0` and `reload/0`.

    Common.lts "Begin loading of TOML files." #T

    toml_map    = LoadTree.load(old_map)
    toml_ndx    = IndexTree.index(toml_map)
    toml_pre    = Schemer.get_prefix()

    toml_map    = toml_map
    |> Map.put(:index,  toml_ndx)
    |> Map.put(:prefix, toml_pre)

    {status, messages} = CheckTree.check_all(toml_map)

#   ii(keyss(toml_map), "keyss(toml_map)") #T
#   ii(toml_ndx, "toml_ndx") #T

    Common.lts "End loading of TOML files." #T

    {status, messages, toml_map}
  end

end
