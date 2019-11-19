# info_web.ex

defmodule InfoWeb do

  @moduledoc """
  This module defines the external API for the InfoWeb component.
  See `info_web/*.ex` for the implementation code.
  """

  alias InfoWeb.{Checker, Common, Server}

  # Define the public interface.

  ## Checker

  @doc delegate_to: {Checker, :check_pages, 0}
  defdelegate check_pages(), to: Checker

  ## Common

  @doc delegate_to: {Common, :validate_uri, 1}
  defdelegate validate_uri(uri_str), to: Common

  ## Server

  @doc delegate_to: {Server, :get_snap, 0}
  defdelegate get_snap(), to: Server

  @doc delegate_to: {Server, :reload, 0}
  defdelegate reload(), to: Server

end