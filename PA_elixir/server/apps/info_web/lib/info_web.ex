# info_web.ex

defmodule InfoWeb do

  @moduledoc """
  This module defines the external API for the InfoWeb component.  See
  `info_web/*.ex` for the implementation code.
  """

  alias InfoWeb.{Checker, Server}

  # Define the public interface.

  @doc """
  Crawl the web site, checking any links found on it.
  ([`Checker`](InfoWeb.Checker.check_pages.html#check_pages/0))
  """
  defdelegate check_pages(),                        to: Checker

  @doc """
  Return the data structure for the latest snapshot.
  ([`Server`](InfoWeb.Server.get_snap.html#get_snap/0))
  """
  defdelegate get_snap(),                           to: Server

  @doc """
  Reload from the snapshot file.
  ([`Server`](InfoWeb.Server.reload.html#reload/0))
  """
  defdelegate reload(),                             to: Server

end