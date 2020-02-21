# phx_http_web/views/_hide.ex

defmodule PhxHttpWeb.View.Hide do
#
# Public functions
#
#   hide_show/2
#     Wrap the hs/3 render call.
#
# Private Functions
#
#   hs/3
#     Render the appropriate `hs_*.html` file.

  @moduledoc """
  This module contains functions to support hide/show toggling.
  """

  use Phoenix.HTML

  alias PhxHttp.Types, as: PHT
  alias PhxHttpWeb.LayoutView

  # Public functions

  @doc """
  Wrap the `hide_show` render call.  The flag may be one of:

  - `"ih:1/1"`, `"is:1/1"` - singleton
  - `"ih:1/2"`, `"is:1/2"` - level 1 of 2
  - `"ih:2/2"`, `"is:2/2"` - level 2 of 2

  The flag's prefix (`ih` or `is`) controls whether the body content
  is initially hidden or shown.  So, for example, `"ih:1/1"` produces
  a singleton (standalone) hide/show in which the body content is
  initially hidden.

      iex> { :safe, io_list } = hide_show("ih:1/1")
      iex> is_list(io_list)
      true

      iex> { :safe, io_list } = hide_show("foo")
      iex> io_list == "!!! invalid control string (foo). !!!"
      true
  """

  @spec hide_show(st) :: PHT.safe_html
    when st: String.t

  def hide_show("ih:1/1"), do: hs("1", "s")
  def hide_show("ih:1/2"), do: hs("1", "s_sa")
  def hide_show("ih:2/2"), do: hs("2", "s")
  def hide_show("is:1/1"), do: hs("1", "h")
  def hide_show("is:1/2"), do: hs("1", "h_ha")
  def hide_show("is:2/2"), do: hs("2", "h")

  def hide_show(bogon) do
    message = "!!! invalid control string (#{ bogon }). !!!"
    { :safe, message }
  end

# Private Functions

  @spec hs(st, st) :: st
    when st: String.t

  defp hs(level, init_mode) do
  #
  # Render the appropriate `hs_*.html` file.

    assigns    = %{ hs_level: level }
    snip_url   = "_hs_#{ init_mode }.html"
    Phoenix.View.render(LayoutView, snip_url, assigns)
  end

end