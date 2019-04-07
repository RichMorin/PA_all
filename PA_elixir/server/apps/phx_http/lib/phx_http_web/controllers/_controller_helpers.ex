# controllers/_controller_helpers.ex

defmodule PhxHttpWeb.ControllerHelpers do
#
# Public functions
#
#   key_ng/2
#     This key is no good; set an error flash and go home...
#
#   nastygram/2
#     Something went wrong; set an error flash and go home...

  @moduledoc """
  This module contains helper functions for controllers. 
  """

  import Phoenix.Controller
  use PhxHttp.Types

  @doc """
  This function is called when a key is not recognized.  It sets up an error
  flash and redirects to the home page.
  """

  @spec key_ng(Plug.Conn.t(), String.t) :: Plug.Conn.t()

  def key_ng(conn, key) do
    message = "That key (#{ key }) was not recognized."
    nastygram(conn, message)
  end

  @doc """
  This function is called when something goes wrong with a web request.  It
  sets up an error flash and redirects to the home page.
  """

  @spec nastygram(Plug.Conn.t(), String.t) :: Plug.Conn.t()

  def nastygram(conn, message) do
    IO.puts "!!!> " <> message

    conn
    |> put_flash(:error, message)
    |> redirect(to: "/")
  end

end
