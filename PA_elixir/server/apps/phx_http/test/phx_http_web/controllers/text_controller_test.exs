# text_controller_test.exs

defmodule PhxHttpWeb.TextControllerTest do

  use PhxHttpWeb.ConnCase

  import ExUnit.CaptureIO

  test "GET /", %{conn: conn} do
    test_fn = fn ->
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "<title>PA Home</title>"
    end

    capture_io(test_fn)
  end

end
