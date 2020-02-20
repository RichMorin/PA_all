# phx_http_web/plugs/bar.ex

defmodule PhxHttpWeb.Plugs.Bar do
#
# Public Functions
#
#   call/2        outputs a divider bar on the console
#   init/1        required by module plug API (noop)
#
# Written by Rich Morin, CFCL, 2020.

  @moduledoc """
  The `Bar` plug  writes a "bar" to the terminal session,
  providing a visual break, time and IP address information, etc.
  ```
  plug PhxHttpWeb.Plugs.Bar
  ```
  """

  # Public Functions

  @doc """
  When the server is running in `:dev` mode, this function displays
  a time-stamped divider (`= = = ...`) on the console for each request.
  """

  @spec call(pc, any) :: pc
    when pc: Plug.Conn.t

  def call(conn, _opts) do
    if Common.get_run_mode() == :dev do #!K
      prefix    = String.duplicate("= ", 5)
      iso8601   = DateTime.utc_now() |> DateTime.to_iso8601()
      ip_addr   = conn.remote_ip |> :inet.ntoa() |> to_string()
      IO.puts "\n#{ prefix }=> #{ iso8601 } from #{ ip_addr }\n"
    end

    conn
  end

  @doc """
  This plug needs no initialization.
  However, the module plug API asks for an `init/1` function.
  """

  @spec init(any) :: false

  def init([]), do: false
    
end
