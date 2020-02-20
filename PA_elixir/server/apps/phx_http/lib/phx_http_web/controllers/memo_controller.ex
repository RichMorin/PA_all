# controllers/mail_controller.ex

defmodule PhxHttpWeb.MemoController do
#
# Public functions
#
#   show/2
#     Send a memo into the storage pool; show the result.

  @moduledoc """
  This module contains controller actions (etc) for handling memos.
  """

  use PhxHttpWeb, :controller

  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  This function sends a memo into the storage pool, then shows the result.
  """
  @spec show(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def show(conn, params) do
    ip_addr     = conn.remote_ip     |> :inet.ntoa() |> to_string()
    iso8601     = DateTime.utc_now() |> DateTime.to_iso8601()
    query_str   = conn.query_string
    req_path    = conn.request_path

    new_memo    = %{
      ip_addr:    ip_addr,
      iso8601:    iso8601,
      params:     params,
      query_str:  query_str,
      req_path:   req_path,
    }

    old_maps    = InfoToml.get_part([:memos])
    old_memos   = Map.get(old_maps, ip_addr, [])

    sort_fn   = fn map -> map.iso8601 end

    memos     = [new_memo | old_memos]
    |> Enum.sort_by(sort_fn)
    |> Enum.reverse()
    |> Enum.take(10)

    old_maps
    |> Map.put(ip_addr, memos)
    |> InfoToml.put_part([:memos])

    conn
    |> base_assigns(:memo_send, "PA Memos")
    |> assign(:memos,           memos)
    |> render("show.html")
  end

end
