# error_test.exs

defmodule PhxHttpWeb.ErrorViewTest do

  use PhxHttpWeb.ConnCase, async: true

  # Bring render/3 and render_to_string/3 for testing custom views
  import Phoenix.View
  alias PhxHttpWeb.ErrorView

  test "renders 404.html" do
    assert render_to_string(
      ErrorView, "404.html", []) == "Not Found"
  end

  test "renders 500.html" do
    assert render_to_string(
      ErrorView, "500.html", []) == "Internal Server Error"
  end
end
