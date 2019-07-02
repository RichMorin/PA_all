# controllers/source_controller.ex

defmodule PhxHttpWeb.SourceController do
#
# Public functions
#
#   down/2
#     Implement the Source download action.
#   show/2
#     Generate data for the Source display page.
#
# Private functions
#
#   get_out_name/1
#     Return an output file name (as used on the client).
#   show_h/3
#     Does the heavy lifting for the show/2 function.

  @moduledoc """
  This module contains controller actions (etc) for printing the TOML
  source files for items in the `"Areas/..."` portion of the `toml_map`.
  """

  use PhxHttpWeb, :controller

  import Common, only: [ ssw: 2 ]
  import InfoToml.Common, only: [ get_file_abs: 1 ]

  alias PhxHttp.Types, as: PT

  # Public functions

  @doc """
  This function implements the Source download action.
  """

  @spec down(PT.conn, any) :: PT.conn #W

  def down(conn, params) do
    key   = params["key"]
    item  = InfoToml.get_item(key)

    if item == nil do
      key_ng(conn, key)
    else
      out_name    = get_out_name(key)
      file_rel    = item.meta.file_rel
      file_abs    = get_file_abs(file_rel)
      cont_disp   = ~s(attachment; filename="#{ out_name }")

      conn
      |> put_resp_header("content-type", "application/toml")
      |> put_resp_header("content-disposition", cont_disp)
      |> send_file(200, file_abs)
    end
  end

  @doc """
  This function generates the Source display page.
  """

  @spec show(PT.conn, any) :: PT.conn #W

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

  @spec get_out_name(s) :: s when s: String.t #W

  defp get_out_name(item_key) do
  #
  # Return an output file name.  This name (as used on the client)
  # is intended to be reminiscent of `item_key`, eg:
  #
  # - `PA__text_about.toml`
  # - `PA_Implementation.toml`

    if item_key =~ ~r{ ^ _ }x do
      inp_patt  = ~r{ ^ ( \w+ ) / ( \w+ ) ( .* ) $ }x
      out_patt  = "PA\\1_\\2.toml"
      item_key |> String.replace(inp_patt, out_patt)
    else
      inp_patt  = ~r{ ^ .+ / ( \w+ ) / ( [^/]+ ) $ }x
      out_patt  = "PA_\\1_\\2"
      item_key |> String.replace(inp_patt, out_patt)
    end
  end

  @spec show_h(PT.conn, String.t, map) :: PT.conn #W

  defp show_h(conn, main_key, main_item) do
  #
  # Does the heavy lifting for the show/2 function.

    base_map  = %{ main_key => main_item}

    item_fn   = fn {key, _title, _precis}, acc ->
    #
    # Build a map of item entries.

      item  = case acc[key] do
        nil   -> InfoToml.get_item(key)
        _     -> acc[key]
      end

      toml_text   = InfoToml.get_toml(key)

      sub_map     = %{
        item:       item,
        name_out:   get_out_name(key),
        toml_text:  toml_text,
      }

      Map.put(acc, key, sub_map)
    end

    base_key    = if ssw(main_key, "_") do
      main_key
    else
      main_key |> String.replace_suffix("/main.toml", "/")
    end
    
    items   = base_key
    |> InfoToml.get_item_tuples()       # [ {<key>, <title>, <precis>}, ... ]
    |> Enum.reduce(base_map, item_fn)   # [ %{...}, ... ]

    conn
    |> base_assigns(:source, "PA Source", main_item, main_key)
    |> assign(:items, items)
    |> render("show.html")
  end

end
