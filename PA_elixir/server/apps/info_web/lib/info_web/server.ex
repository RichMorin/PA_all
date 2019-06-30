# info_web/server.ex

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
#   first_load/0
#     Handle initial loading of data.

  @moduledoc """
  This module implements both the external API (eg, `get_info/1`) and the
  setup ceremony (eg, `start_link/0`) for the OTP server.
  """

  @me __MODULE__

  use InfoWeb.Types

  alias InfoWeb.Snapshot

  # Public functions

  @doc """
  Return the data structure for the latest snapshot.  Note that the keys
  are strings, rather than atoms.

      %{
        "bins" => %{
          "ext_ng" => [ [ "<url>", "<from>", "<status>" ], ... ],
          "int_ng" => [ [ "<url>", "<from>", "<status>" ], ... ]
        },
        "counts" => %{
          "ext" => %{ "<site>"  => <count>, ... },
          "int" => %{ "<route>" => <count>, ... }
        },
        "raw" => %{
          "ext_ok" => [ "<url>", ... ]
        }
      }
  """

  @spec get_snap() :: map

  def get_snap(), do: Agent.get(@me, &(&1) )

  @doc """
  Reload from the snapshot file.
  """

  @spec reload() :: any #K

  def reload() do
    snap_map    = Snapshot.snap_load()

    update_fn   = fn _ignore -> snap_map end
    #
    # Return new snapshot, ignoring the current one.

    Agent.update(@me, update_fn)
    {:info,  "Updated without problems."}
  end

  @doc """
  Start up the server Agent.
  """

  @spec start_link() :: {atom, pid | String.t } #W

  def start_link(), do: Agent.start_link(&first_load/0, name: @me)

  # Private functions

  @spec first_load() :: map #W

  defp first_load(), do: Snapshot.snap_load()
  #
  # Handle initial loading of data.

end
