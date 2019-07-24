# controllers/_zoo.ex

defmodule PhxHttpWeb.Cont.Zoo do
#
# Public functions
#
#   base_assigns/5
#     Perform a set of base assigns.
#   key_ng/2
#     This key is no good; set an error flash and go home...
#   nastygram/2
#     Something went wrong; set an error flash and go home...

  @moduledoc """
  This module contains helper functions for controllers. 
  """

  import Phoenix.Controller

  alias InfoToml.Types, as: ITT

  # Public functions

  @doc """
  This function performs several base assigns:
  
  - `:item`       - item map, if any
  - `:key`        - item key, if any
  - `:page_type`  - page type atom
  - `:title`      - page title string
  """

  @spec base_assigns(pc, atom, st, im, st | nil) :: pc
    when im: ITT.item_maybe, pc: Plug.Conn.t, st: String.t

  def base_assigns(conn, page_type, title, item \\ nil, key \\ nil) do
    import Plug.Conn, only: [ assign: 3 ]

    conn
    |> assign(:item,      item)
    |> assign(:key,       key)
    |> assign(:page_type, page_type)
    |> assign(:title,     title)
  end

  @doc """
  This function is called when a key is not recognized.
  It sets up an error flash and redirects to the home page.
  """

  @spec key_ng(pc, String.t) :: pc
    when pc: Plug.Conn.t

  def key_ng(conn, key) do
    message = "That key (#{ key }) was not recognized."
    nastygram(conn, message)
  end

  @doc """
  This function is called when something goes wrong with a web request.
  It sets up an error flash and redirects to the home page.
  """

  @spec nastygram(pc, String.t) :: pc
    when pc: Plug.Conn.t

  def nastygram(conn, message) do
    IO.puts "!!!> " <> message

    conn
    |> put_flash(:error, message)
    |> redirect(to: "/")
  end

end
