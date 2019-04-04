defmodule InfoWeb do

  @moduledoc """
  This module defines the external API for the InfoWeb component.  See
  `info_web/*.ex` for the implementation code.
  
  Note: It also sets up some infrastructure for code sharing.
  """

  alias InfoWeb.{Checker}

  # Define the public interface.

  @doc """
  Crawl the specified web site, checking any links found on it.
  ([`...Checker.check_links/1`](InfoWeb.Checker.check_links.html#check_links/1))
  """
  defdelegate check_links(base_url),                to: Checker

  @doc """
  Return the data structure for a link, given its URL.
  ([`...Server.get_info/1`](InfoWeb.Server.get_info.html#get_info/1))
  """
  defdelegate get_info(link_url),                   to: Server

  @doc """
  Update the data structure for a link, given its URL and a new value.
  ([`...Server.put_info/1`](InfoWeb.Server.put_info.html#put_info/1))
  """
  defdelegate put_info(link_url),                   to: Server


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

  def get_calls(), do: Mix.Tasks.Xref.calls #D

end