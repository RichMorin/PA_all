# controllers/_helpers.ex

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

  use PhxHttp.Types

  import Phoenix.Controller

  # Public functions

  @doc """
  This function performs several base assigns:
  
  - :item       - item map, if any
  - :key        - item key, if any
  - :page_type  - page type atom
  - :title      - page title string
  """

  @spec base_assigns(pc, atom, s, map|nil, s|nil) :: pc
    when pc: Plug.Conn.t(), s: String.t #W

  def base_assigns(conn, page_type, title, item \\ nil, key \\ nil) do
    import Plug.Conn, only: [ assign: 3 ]

    conn
    |> assign(:item,      item)
    |> assign(:key,       key)
    |> assign(:page_type, page_type)
    |> assign(:title,     title)
  end

  @doc """
  This function is called when a key is not recognized.  It sets up an error
  flash and redirects to the home page.
  """

  @spec key_ng(Plug.Conn.t(), String.t) :: Plug.Conn.t() #W

  def key_ng(conn, key) do
    message = "That key (#{ key }) was not recognized."
    nastygram(conn, message)
  end

  @doc """
  This function is called when something goes wrong with a web request.  It
  sets up an error flash and redirects to the home page.
  """

  @spec nastygram(Plug.Conn.t(), String.t) :: Plug.Conn.t() #W

  def nastygram(conn, message) do
    IO.puts "!!!> " <> message

    conn
    |> put_flash(:error, message)
    |> redirect(to: "/")
  end

end
