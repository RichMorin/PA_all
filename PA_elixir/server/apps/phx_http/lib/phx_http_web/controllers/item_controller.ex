# controllers/item_controller.ex

defmodule PhxHttpWeb.ItemController do
#
# Public functions
#
#   show/2
#     Display a specified item.
#
# Private functions
#
#   show_h/2
#     Handle item requests, with and without a key.
#   show_h2/2
#     Fold some `make.toml` info into the item.
#   show_h3/4
#     Gather up some `make.toml` info.

  @moduledoc """
  This module contains controller actions (etc) for displaying specified
  items in the "Areas/..." portion of the `toml_map`.
  """

  use PhxHttpWeb, :controller

  import PhxHttpWeb.Cont.Items,
    only: [ get_make: 1, get_reviews: 1 ]

  alias InfoToml.Types, as: ITT
  alias PhxHttp.Types,  as: PHT

  # Public functions


  @doc """
  This function displays a specified item.
  """

  @spec show(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def show(conn, params) do
    key   = params["key"]

    show_h(conn, key)
  end

  # Private Functions

  @spec show_h(pc, nil) :: pc
    when pc: Plug.Conn.t

  defp show_h(conn, nil) do
  #
  # Handle requests with no key.

    message = "No key was specified for the item."
    nastygram(conn, message)
  end

  @spec show_h(pc, String.t) :: pc
    when pc: Plug.Conn.t

  defp show_h(conn, key) do
  #
  # Handle requests that have a key.  If the key doesn't match an item,
  # redirect to the most appropriate Area page.

    item    = InfoToml.get_item(key)

    if item == nil do
      message   = "Sorry, I don't recognize that item. " <>
                  "Please examine this Area page for alternatives."

      conn
      |> put_flash(:error, message)
      |> redirect(to: "/area?key=#{ InfoToml.get_area_key(key) }")
    else
      item      = show_h2(item, key)
      reviews   = get_reviews(key)

      conn
      |> base_assigns(:item, "PA Item", item, key)
      |> assign(:reviews,     reviews)
      |> render("show.html")
    end
  end

  @spec show_h2(im, String.t) :: im
    when im: ITT.item_map

  defp show_h2(item, key) do
  #
  # Fold some `make.toml` info into the item.

    make_item   = get_make(key)

    if make_item == nil do
      item
    else
      arch_pi   = ~w(os arch package)a
      arch_po   = ~w(address related arch)a

      deb_pi    = ~w(os debian package)a
      deb_po    = ~w(address related debian)a

      item
      |> show_h3(make_item, arch_pi, arch_po)
      |> show_h3(make_item, deb_pi,  deb_po)
    end
  end

  @spec show_h3(im, im, [atom], [atom]) :: im
    when im: ITT.item_map

  defp show_h3(item, make_item, path_inp, path_out) do
  #
  # Gather up some `make.toml` info.

    value   = get_in(make_item, path_inp)

    if value do
      gi_path   = ~w(address related)a
      item      = if get_in(item, gi_path) do
        item
      else
        put_in(item, gi_path, %{})
      end

      put_in(item, path_out, value)
    else
      item
    end
  end

end
