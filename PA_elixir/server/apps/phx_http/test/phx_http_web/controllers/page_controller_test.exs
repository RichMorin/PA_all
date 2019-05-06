# page_controller_test.exs

defmodule PhxHttpWeb.PageControllerTest do

  use PhxHttpWeb.ConnCase

  import ExUnit.CaptureIO

  test "GET /", %{conn: conn} do
    fun = fn ->
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Pete's Alley"
    end
    capture_io(fun)
  end
end
