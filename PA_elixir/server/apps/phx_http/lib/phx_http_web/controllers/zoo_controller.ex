# controllers/zoo_controller.ex

defmodule PhxHttpWeb.ZooController do
#
# Public functions
#
#   show/2
#     Handle invalid request paths.

  @moduledoc """
  This module contains a controller action to handle invalid request paths.
  """

  use PhxHttpWeb, :controller

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  This function handles invalid request paths.
  """

  @spec show(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def show(conn, _params) do
    req_path  = conn.request_path
    message   = "That request path (#{ req_path }) was not recognized."
    nastygram(conn, message)
  end

end
