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
#   get_slides/1
#     Get Markdown for slides, if any.
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
    only: [get_make: 1, get_reviews: 1, get_slide_keys: 1]

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

  @spec get_slides(st) :: st
    when st: String.t

  defp get_slides(slide_keys) do
  #
  # Get Markdown for slides, if any.

    if Enum.empty?(slide_keys) do
      ""
    else
      reduce_fn = fn slide_key, acc ->
        slide_item  = InfoToml.get_item(slide_key)
        slide_av    = slide_item.about.verbose
        slide_mt    = slide_item.meta.title
        title_md    = "#### #{ slide_mt }\n" 

        [ title_md <> slide_av | acc ]
      end

      slide_keys                        # [ ".../s_0000_Title.toml", ... ]
      |> Enum.reverse()                 # [ ..., ".../s_0000_Title.toml" ]
      |> Enum.reduce([], reduce_fn)     # [ ..., "### Perkify: ..." ]
      |> Enum.join("\n")                # "### Perkify: ..."
    end
  end

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

  defp show_h(conn, item_key) do
  #
  # Handle requests that have a key.  If the key doesn't match an item,
  # redirect to the most appropriate Area page.

    item    = InfoToml.get_item(item_key)

    if item == nil do
      area_key  = InfoToml.get_area_key(item_key)
      message   = "Sorry, I don't recognize that item. " <>
                  "Please examine this Area page for alternatives."

      conn
      |> put_flash(:error, message)
      |> redirect(to: "/area?key=#{ area_key }")
    else
      reviews     = get_reviews(item_key)
      slide_keys  = get_slide_keys(item_key)
      slide_text  = get_slides(slide_keys)

      item        = item
      |> show_h2(item_key)

      conn
      |> base_assigns(:item, "PA Item", item, item_key)
      |> assign(:reviews,     reviews)
      |> assign(:slide_keys,  slide_keys)
      |> assign(:slide_text,  slide_text)
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
