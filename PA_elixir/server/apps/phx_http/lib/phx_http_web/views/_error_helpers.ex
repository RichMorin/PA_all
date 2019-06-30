# phx_http_web/views/error_helpers.ex

defmodule PhxHttpWeb.ErrorHelpers do
#
# Public functions
#
#   error_tag/2
#     Generates tag for inlined form input errors.
#   translate_error/2
#     Translates an error message using gettext.

  @moduledoc """
  Conveniences for translating and building error messages.
  """

  use Phoenix.HTML

  # Public functions

  @doc """
  This function generates a tag for inlined form input errors.
  """

# @spec - ToDo

  def error_tag(form, field) do

    error_fn  = fn error ->
      content_tag(:span, translate_error(error), class: "help-block")
    end

    Enum.map(Keyword.get_values(form.errors, field), error_fn)
  end

  @doc """
  This function translates an error message using `gettext`.
  """

# @spec - ToDo

  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate "is invalid" in the "errors" domain
    #     dgettext("errors", "is invalid")
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # Because the error messages we show in our forms and APIs
    # are defined inside Ecto, we need to translate them dynamically.
    # This requires us to call the Gettext module passing our gettext
    # backend as first argument.
    #
    # Note we use the "errors" domain, which means translations
    # should be written to the errors.po file. The :count option is
    # set by Ecto and indicates we should also apply plural rules.
    if count = opts[:count] do
      Gettext.dngettext(PhxHttpWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(PhxHttpWeb.Gettext, "errors", msg, opts)
    end
  end

end
