# controllers/area_controller.ex

defmodule PhxHttpWeb.AreaController do
#
# Public functions
#
#   reload/2
#     Reload the site's content.
#   show/2
#     Show a summary page for a specified part of the Areas tree.
#
# Private functions
#
#   get_tidy_tuples/1
#     Get a sorted (by title) and filtered list of item tuples.
#   reload_h/2
#     Helper for reload/2 - actually performs the reload
#   show_h/3
#    Summarize the site's areas at various levels (mostly 1-3).

  @moduledoc """
  This module contains controller actions (etc) for the "Areas/..." portion
  of the `toml_map`.  It also handles reloading of the InfoToml server.
  """

  use PhxHttpWeb, :controller

  import Common, only: [ get_run_mode: 0, sort_by_elem: 3 ]

  import InfoToml,
    only: [ get_area_name: 1, get_area_names: 0, get_area_names: 1 ]

  alias Common.Types,  as: CT
  alias PhxHttp.Types, as: PT

  # Public functions

  @doc """
  This function causes the server to reload the site's content from the TOML
  tree.  In general, session information should still be retained and valid.
  """

  @spec reload(PT.conn, any) :: PT.conn #W

  def reload(conn, params) do
  #
  #K Checking `get_run_mode/0` and the remote (really, router) IP address
  # is a hack.  If used with public access, this should check the user ID.

    if conn.remote_ip != { 192, 168, 1, 1 } do

      if get_run_mode() == :dev do #K
        reload_h(conn, params)
      else
        message = "Reloading is only supported in development mode."
        nastygram(conn, message)
      end

    else
      message = "Reloading is only supported for local users."
      nastygram(conn, message)
    end
  end

  @doc """
  This function displays a summary page for a specified part of the Areas tree.
  """

  @spec show(PT.conn, any) :: PT.conn #W

  def show(conn, params) do
  #
  # Parcel out the work.

    key     = params["key"] || "Areas/_area.toml"

    level   = ( key
    |> String.split("/")
    |> Enum.count() ) - 1

    show_h(conn, level, key)  
  end

  # Private Functions

  @spec get_tidy_tuples(String.t) :: list #W

  defp get_tidy_tuples(key) do
  #
  # Get a sorted (by title) and filtered list of item tuples, given a key.

    main_fn   = fn {path, _title, _precis} ->
    #
    # Return true if this is the main file for an item.

      text_patt   = ~r{ / main \. toml $ }x
      String.match?(path, text_patt)
    end

    key
    |> String.replace_trailing("/_area.toml", "")
    |> InfoToml.get_item_tuples()
    |> Enum.filter(main_fn)
    |> sort_by_elem(1, :dc)
  end

  @spec reload_h(PT.conn, any) :: PT.conn #W

  defp reload_h(conn, params) do
  #
  # Helper for reload/2 - actually performs the reload
  #
  #K This is a hack; it should probably check user ID or somesuch...

    time_1      = Time.utc_now()
    { status_it,  message_it} = InfoToml.reload()
    {_status_iw, _message_iw} = InfoWeb.reload()
    time_2      = Time.utc_now()

    millisecs   = Time.diff(time_2, time_1, :millisecond)
    message_d   = "Duration was #{ millisecs } ms."
    message_c   = "#{ message_it } #{ message_d }"

    prev_url = case params["redirect"] do
      nil   ->  "/"
      path  ->  path
    end

    status_c = status_it  #K #ToDo - check for InfoWeb issues.

    conn
    |> put_flash(status_c, message_c)
    |> redirect(to: prev_url)
  end

  @spec show_h(PT.conn, integer, String.t) :: PT.conn #W

  defp show_h(conn, 1, key) do
  #
  # Summarize the site's areas at level 1 (`Areas`).

    item  = InfoToml.get_item(key)

    section_fn = fn area, acc ->
    #
    # Build a list of sections for this area.

      tuple = { area, get_area_names(area) }
      [ tuple | acc ]
    end

    tuples  = get_area_names()
    |> Enum.reduce([], section_fn)
    |> Enum.reverse()

    conn
    |> base_assigns(:area_1, "PA Areas", item, key)
    |> assign(:tuples, tuples)
    |> render("show_1.html")
  end

  defp show_h(conn, 2, key) do
  #
  # Summarize the site's areas at level 2 (eg, `Areas/Content`).

    item      = InfoToml.get_item(key)

    if item == nil do
      key_ng(conn, key)
    else
      count_fn  = fn {path, _title, _precis}, acc ->
      #
      # Build a map of counts, indexed by section name.

        patt      = ~r{ ^ [^/]+ / [^/]+ / ( [^/]+ ) / .+ $ }x
        section   = String.replace(path, patt, "\\1")

        Map.update(acc, section, 1, &(&1 + 1) )
      end

      counts  = key
      |> get_tidy_tuples()
      |> Enum.reduce(%{}, count_fn)

      name      = get_area_name(key)
      sections  = get_area_names(name)

      conn
      |> base_assigns(:area_2, "PA Areas", item, key)
      |> assign(:counts,      counts)
      |> assign(:name,        name)
      |> assign(:sections,    sections)
      |> render("show_2.html")
    end
  end

  defp show_h(conn, 3, key) do
  #
  # Summarize the site's areas at level 3 (eg, `Areas/Content/HowTos`).

    item  = InfoToml.get_item(key)
    name  = get_area_name(key)

    if item == nil do
      key_ng(conn, key)
    else
      show_h3(conn, name, key, item)
    end
  end

  defp show_h(conn, _, key), do: key_ng(conn, key)
  #
  # Handle bogus levels.

  @spec show_h3(PT.conn, s, s, CT.item_map) :: PT.conn when s: String.t #W

  defp show_h3(conn, name, key, item) do
  #
  # Help out show_h/3 at level 3.

    real_items  = get_tidy_tuples(key)
    item_cnt    = Enum.count(real_items)

    heading_fn  = fn {_, title, _} ->
    #
    # Extract an upper-cased heading character (e.g., "A") from the title.

      title
      |> String.first()
      |> String.upcase()
    end

    first_chars = real_items
    |> Enum.map(heading_fn)
    |> Enum.sort()
    |> Enum.uniq()

    tuple_fn    = fn title -> {nil, title, nil} end
    #
    # Fake up a tuple, using a letter for the title component.

    fake_items  = first_chars |> Enum.map(tuple_fn)

    sort_items  = (fake_items ++ real_items)
    |> sort_by_elem(1, :dc)

    conn
    |> base_assigns(:area_3, "PA Areas", item, key)
    |> assign(:first_chars,   first_chars)
    |> assign(:item_cnt,      item_cnt)
    |> assign(:name,          name)
    |> assign(:sort_items,    sort_items)
    |> render("show_3.html")
  end

end
