# controllers/text_controller.ex

defmodule PhxHttpWeb.TextController do
#
# Public functions
#
#   show/2
#     Generate data for the Text display page.

  @moduledoc """
  This module contains controller actions (etc) for formatting and
  printing TOML-encoded text files for items in the "_text/..." portion
  of the `toml_map`.
  """

  use PhxHttp.Types
  use PhxHttpWeb, :controller
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  This function generates the Text display page.
  """

  @spec show(conn, params) :: conn

  def show(conn, params) do
    key   = params["key"] || "_text/home.toml"
    item  = InfoToml.get_item(key)

    if item == nil do
      key_ng(conn, key)
    else
      pattern = ~r{ ^_text / ( \w+ ) .* $ }x
      name    = key  |> String.replace(pattern, "\\1")
      title   = name |> String.capitalize()

      conn
      |> assign(:item,        item)
      |> assign(:key,         key)
      |> assign(:page_type,   :text)
      |> assign(:title,       "PA #{ title }")
      |> render("#{ name }.html")
    end
  end

end
