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

  def get_snap() do
    get_fn = fn snapshot -> snapshot end

    Agent.get(@me, get_fn)
  end

  @doc """
  Reload from the snapshot file.
  """

  @spec reload() :: any #K

  def reload() do
    snap_map    = Snapshot.snap_load()
    update_fn   = fn _ignore -> snap_map end

    Agent.update(@me, update_fn)
    {:info,  "Updated without problems."}
  end

  @doc """
  Start up the server Agent.
  """

  @spec start_link() :: {atom, pid | String.t } #W

  def start_link() do
    Agent.start_link(&first_load/0, name: @me)
  end

  # Private functions

  @spec first_load() :: map #W

  defp first_load() do
  #
  # Handle initial loading of data.

    Snapshot.snap_load()
  end

end
