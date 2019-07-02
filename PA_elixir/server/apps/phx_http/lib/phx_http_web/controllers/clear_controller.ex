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

  use PhxHttpWeb, :controller

  import Common, only: [ ssw: 2 ]

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

    key_fn      = fn {key, _val} -> key end
    #
    # Extract the key from a map tuple.

    noise_fn    = fn {key, val} -> ssw(key, "_") || val == "n" end
    #
    # Return true for "noise" parameters.

    clear       = params
    |> Enum.reject(noise_fn)      # [ {"a", "y"}, ... ]
    |> Enum.map(key_fn)           # [ "a", ... ]

    clear_fn   = fn {key, _val} -> Enum.member?(clear, key) end
    #
    # Return true for queries the user wants to clear.

    tag_sets    = conn
    |> get_session(:tag_sets)
    |> Enum.reject(clear_fn)
    |> Enum.into(%{})

    conn        = put_session(conn, :tag_sets, tag_sets) #D
    redirect(conn, to: "/search/find")
  end

end
