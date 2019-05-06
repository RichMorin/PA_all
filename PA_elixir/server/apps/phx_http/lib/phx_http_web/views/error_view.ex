# phx_http_web/views/error_view.ex

defmodule PhxHttpWeb.ErrorView do
#
# Public functions
#
#   template_not_found/2
#     Returns the status message from the template name.

  use PhxHttpWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".

  # Public functions

# @spec - ToDo

  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

end
