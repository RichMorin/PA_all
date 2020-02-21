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
    authors     = rev_item.meta.refs.f_authors
    editors     = rev_item.meta.refs.f_authors
    bylines     = fmt_bylines(authors, editors)
    precis      = rev_item.about.precis
    verbose     = fmt_section(rev_item, [:about, :verbose])

    ~E"""
    <h4><%= bylines %></h4>
    <p><%= hide_show("is:1/1") %></p>
    <%= fmt_precis(precis) %>
    <div class="hs-body1">
      <%= verbose %>
    </div>
    """
  end

end
