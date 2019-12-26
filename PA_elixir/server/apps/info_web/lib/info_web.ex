# info_web.ex

defmodule InfoWeb do

  @moduledoc """
  This module defines the external API for the InfoWeb component.
  See `info_web/*.ex` for the implementation code.
  """

  alias InfoWeb.{Checker, Common, Server}

  # Define the public interface.

  ## Checker

  defdelegate check_pages(),                      to: Checker

  ## Common

  defdelegate validate_uri(uri_str),              to: Common

  ## Server

  defdelegate get_snap(),                         to: Server
  defdelegate reload(),                           to: Server

end