# controllers/area_controller.ex

defmodule PhxHttpWeb.AreaController do
#
# Public functions
#
#   reload/2
#     Reload the site's content.
#   show/2
#     Show a summary page for a specified part of the Areas tree.
#
# Private functions
#
#   reload_h/2
#     Helper for reload/2 - actually performs the reload

  @moduledoc """
  This module contains controller actions (etc) for the "Areas/..." portion
  of the `toml_map`.  It also handles reloading of the InfoToml server.
  """

  use PhxHttpWeb, :controller

  import PhxHttpWeb.Cont.Levels
  import Common, only: [chk_local: 1, get_run_mode: 0]

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  This function causes the server to reload the site's content from the TOML
  tree.  In general, session information should still be retained and valid.
  """

  @spec reload(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def reload(conn, params) do
  #
  #!K Checking for a local IP address and `get_run_mode/0` is a hack.
  #   If used with public access, this should check the user ID.

    if chk_local(conn) do

      if get_run_mode() == :dev do #!K
        reload_h(conn, params)
      else
        message = "Reloading is only supported in development mode."
        nastygram(conn, message)
      end

    else
      message = "Reloading is only supported for local users."
      nastygram(conn, message)
    end
  end

  @doc """
  This function displays a summary page for a specified part of the Areas tree.
  """

  @spec show(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def show(conn, params) do
  #
  # Parcel out the work.

    key     = params["key"] || "Areas/_area.toml"

    level   = ( key
    |> String.split("/")
    |> Enum.count() ) - 1

    show_h(conn, level, key)  
  end

  # Private Functions

  @spec reload_h(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  defp reload_h(conn, params) do
  #
  # Helper for reload/2 - actually performs the reload
  #
  #!K This is a hack; it should probably check user ID or somesuch...

    time_1      = Time.utc_now()
    { status_it,  message_it} = InfoToml.reload()
    {_status_iw, _message_iw} = InfoWeb.reload()
    time_2      = Time.utc_now()

    millisecs   = Time.diff(time_2, time_1, :millisecond)
    message_d   = "Duration was #{ millisecs } ms."
    message_c   = "#{ message_it } #{ message_d }"

    prev_url = case params["redirect"] do
      nil   ->  "/"
      path  ->  path
    end

    status_c = status_it  #!K ToDo - check for InfoWeb issues.

    conn
    |> put_flash(status_c, message_c)
    |> redirect(to: prev_url)
  end

end
