# controllers/slide_controller.ex

defmodule PhxHttpWeb.SlideController do
#
# Public functions
#
#   show/2
#     Generate data for the Slide display page.
#
# Private functions
#
#   get_out_name/1
#     Return an output file name (as used on the client).
#   show_h/3
#     Does the heavy lifting for the show/2 function.

  @moduledoc """
  This module contains controller actions (etc) for printing slides.
  """

  use PhxHttpWeb, :controller

  import PhxHttpWeb.Cont.Items, only: [ get_slides: 1 ]

  alias InfoToml.Types, as: ITT
  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  This function generates the Slide display page.
  """

  @spec show(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def show(conn, params) do
    key     = params["key"]
    item    = InfoToml.get_item(key)

    if item == nil do
      key_ng(conn, key)
    else
      show_h(conn, key, item)
    end
  end

  # Private functions

  @spec show_h(pc, String.t, ITT.item_map) :: pc
    when pc: Plug.Conn.t

  defp show_h(conn, key, item) do
  #
  # Does the heavy lifting for the show/2 function.

    conn
    |> base_assigns(:slide, "PA Slide", item, key)
    |> assign(:slides, get_slides(key))
    |> render("show.html")
  end

end
