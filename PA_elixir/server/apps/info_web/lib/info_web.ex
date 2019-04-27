defmodule InfoWeb do

  @moduledoc """
  This module defines the external API for the InfoWeb component.  See
  `info_web/*.ex` for the implementation code.
  
  Note: It also sets up some infrastructure for code sharing.
  """

  alias InfoWeb.{Checker, Server}

  # Define the public interface.

  @doc """
  Crawl the web site, checking any links found on it.
  ([`...Checker.check_links/0`](InfoWeb.Checker.check_links.html#check_links/0))
  """
  defdelegate check_links(),                        to: Checker

  @doc """
  Return the data structure for the latest snapshot.
  ([`...Server.get_snap/0`](InfoWeb.Server.get_snap.html#get_snap/0))
  """
  defdelegate get_snap(),                           to: Server

  @doc """
  Reload from the snapshot file.
  ([`...Server.reload/0`](InfoWeb.Server.reload.html#reload/0))
  """
  defdelegate reload(),                             to: Server


  @doc "Set up infrastructure for code sharing."
  def common do
    quote do
      import InfoWeb.Common
    end
  end

  @doc """
  Dispatch to the appropriate module (e.g., `use InfoWeb, :common`).
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

end