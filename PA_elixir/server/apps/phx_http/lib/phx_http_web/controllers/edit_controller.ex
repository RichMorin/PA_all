# controllers/edit_controller.ex

defmodule PhxHttpWeb.EditController do
#
# Public functions
#
#   edit_form/2
#     Generate the edit_form page.
#   edit_post/2
#     Handle the edit_post action.
#
# Private functions

  @moduledoc """
  This module contains controller actions (etc) for displaying specified
  items in the "Areas/..." portion of the `toml_map`.
  """

  use Common.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  import PhxHttpWeb.ItemController,
    only: [ get_gi_bases: 1, get_gi_pairs: 1, get_item_map: 2 ]

  # Public functions

  @doc """
  This function generates the `edit_form` page.
  """

  @spec edit_form(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def edit_form(conn, params) do
    schema    = "_schemas/main.toml" |> InfoToml.get_item()
    key       = params["key"]
    item      = InfoToml.get_item(key)

    conn  = if (key != nil) && (item == nil) do
      message = "Sorry, the specified key (#{ key }) was not found, " <>
                "so no data was loaded."
      put_flash(conn, :error, message) 
    else
      conn
    end

    conn
    |> base_assigns(:edit_f, "PA Edit", item, key)
    |> assign(:schema,      schema)
    |> render("edit.html")
  end

  @doc """
  This function handles the `edit_post` action.
  """

  @spec edit_post(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def edit_post(conn, params) do

    gi_pairs    = get_gi_pairs(params)
    gi_bases    = get_gi_bases(gi_pairs)
    item_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_items" #K
    item_key    = params["key"]
    item_map    = get_item_map(gi_bases, gi_pairs)
    item_toml   = InfoToml.get_item_toml(gi_bases, item_map)
#   item        = InfoToml.get_item(item_key)
    schema      = "_schemas/main.toml" |> InfoToml.get_item()

    case params["button"] do
      "Preview" ->
        conn
        |> base_assigns(:edit_p, "PA Edit")
        |> assign(:item,        item_map)
        |> assign(:item_toml,   item_toml)
        |> assign(:key,         item_key)
        |> assign(:schema,      schema)
        |> render("preview.html")

      "Submit" ->
        save_path = InfoToml.emit_toml(item_base, ".item", item_toml)
        save_name = String.replace(save_path, ~r{ ^ .+ / }x, "")
        message   = """
        Your submission has been saved as "#{ save_name }".
        Feel free to use this Edit page as a new starting point.
        """

        conn
        |> put_flash(:info,     message)
        |> base_assigns(:edit_s, "PA Edit")
        |> assign(:item,        item_map)
        |> assign(:key,         item_key)
        |> assign(:schema,      schema)
        |> render("edit.html")
    end
  end

end
