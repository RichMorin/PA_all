# phx_http_web/views/item_view.ex

defmodule PhxHttpWeb.ItemView do
#
# Public functions
#
#   fmt_review/1
#     Format a review for display.

  @moduledoc """
  This module supports rendering of the `item` templates.
  """

  use Phoenix.HTML
  use PhxHttpWeb, :view

  import PhxHttpWeb.View.Address
  import PhxHttpWeb.View.Hide

  alias PhxHttp.Types, as: PHT

  # Public functions

  @doc """
  Format a review for display.

      iex> rev_key  = "Areas/Catalog/Hardware/Anova_PC/text.Rich_Morin.toml"
      iex> { :safe, io_list } = fmt_review(rev_key)
      iex> is_list(io_list)
      true
  """

  @spec fmt_review(String.t) :: PHT.safe_html

  def fmt_review(rev_key) do
    rev_item    = InfoToml.get_item(rev_key)
    f_authors   = rev_item.meta.refs.f_authors
    precis      = rev_item.about.precis
    verbose     = fmt_markup(rev_item, [:about, :verbose])
    auth_out    = fmt_authors(f_authors)

    ~E"""
    <div class="hs-base2">
      <h4>
        <%= auth_out %>
        <%= hide_show("is:2/2", "full review for this item") %>
      </h4>
      <%= fmt_precis(precis) %>
      <div class="hs-body2">
        <%= verbose %>
      </div>
    </div>
    """
  end

end
