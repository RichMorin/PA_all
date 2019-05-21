# controllers/clear_controller.ex

defmodule PhxHttpWeb.ClearController do
#
# Public functions
#
#   clear_form/2
#     Generate data for the Clear Searches (form) page.
#   clear_post/2
#     Do any requested clearing, then redirect to the Search page.

  @moduledoc """
  This module contains controller actions (etc) for clearing Search queries.
  """

  use PhxHttp.Types
  use PhxHttpWeb, :controller

  # Public functions

  @doc """
  This function generates data for the Clear Searches page, where the user
  fills in a form.
  """

  @spec clear_form(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def clear_form(conn, _params) do
    sess_tag_sets   = get_session(conn, :tag_sets) || []

    conn
    |> base_assigns(:search_c, "PA Clear")
    |> assign(:page_type,       :search_c)
    |> assign(:sess_tag_sets,   sess_tag_sets)
    |> render("clear.html")
  end

  @doc """
  This function does any requested clearing of queries, then redirects
  to the Search page.
  """

  @spec clear_post(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def clear_post(conn, params) do
    map_fn      = fn {key, _val} -> key end

    reject_fn_1 = fn {key, val} ->
      String.starts_with?(key, "_") || val == "n"
    end

    remove  = params
    |> Enum.reject(reject_fn_1)   # [ {"a", "y"}, ... ]
    |> Enum.map(map_fn)           # [ "a", ... ]

    reject_fn_2 = fn {key, _val} -> Enum.member?(remove, key) end

    tag_sets    = conn
    |> get_session(:tag_sets)
    |> Enum.reject(reject_fn_2)
    |> Enum.into(%{})

    conn        = put_session(conn, :tag_sets, tag_sets) #D
    redirect(conn, to: "/search/find")
  end

end
