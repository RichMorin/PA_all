# controllers/area_controller.ex

defmodule PhxHttpWeb.AreaController do
#
# Private macros
#
#   get_areas/0
#     Returns a list of Area names, eg: [ "Catalog", ... ]
#   get_areas/1
#     Returns a list of Section names, eg: [ "Groups", ... ]
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
#   get_area_name(key) do
#     Get the name of an Area, given a key in it.
#   get_items/1
#     Get a sorted (by title) and filtered list of items, given a key.
#   reload_h/2
#     Helper for reload/2 - actually performs the reload
#   show_h/3
#    Summarize the site's areas at various levels (mostly 1-3).

  @moduledoc """
  This module contains controller actions (etc) for the "Areas/..." portion
  of the `toml_map`.  It also handles reloading of the InfoToml server.
  """

  use InfoToml, :common
  use InfoToml.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  import Common

  # Private macros

  @spec get_areas() :: [ String.t ] #W

  defmacrop get_areas() do
  #
  # Returns a list of Area names: [ "Catalog", ... ]

    quote do
      reject_fn = fn key ->
        key =~ ~r{ ^ _ }x || key =~ ~r{ \. toml $ }x
      end

      map_fn  = fn key -> key |> String.replace(~r{ ^ .* / }x, "") end

      InfoToml.get_keys(2)
      |> Enum.reject(reject_fn)
      |> Enum.map(map_fn)
    end
  end

  @spec get_areas(s) :: s when s: [ String.t ] #W

  defmacrop get_areas(area) do
  #
  # Given "Content", returns [ "HowTos", ... ]

    quote do
      test_str   = "Areas/#{ unquote(area) }"

      filter_fn = fn key ->
        String.starts_with?(key, test_str)  &&
        !( key =~ ~r{ \. toml $ }x )
      end

      map_fn  = fn key ->
        key
        |> String.replace(~r{ ^ .* / }x, "")
      end

      InfoToml.get_keys(3)
      |> Enum.filter(filter_fn)
      |> Enum.map(map_fn)
    end
  end

  # Public functions

  @doc """
  This function causes the server to reload the site's content from the TOML
  tree.  In general, session information should still be retained and valid.
  """

  @spec reload(Plug.Conn.t(), any) :: Plug.Conn.t() #W

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

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t() #W

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

  @spec get_area_name(String.t) :: String.t #W

  defp get_area_name(key) do
  #
  # Get the name of an Area, given a key in it.

    pattern   = ~r{ ^ .* / ( \w+ ) / [^/]+ $ }x
    String.replace(key, pattern, "\\1")
  end

  @spec get_items(String.t) :: list #W

  defp get_items(key) do
  #
  # Get a sorted (by title) and filtered list of items, given a key.

    filter_fn   = fn {path, _title, _precis} ->
      text_patt   = ~r{ / main \. toml $ }x
      String.match?(path, text_patt)
    end

    sort_fn     = fn {_path, title, _precis} -> String.downcase(title) end

    key
    |> String.replace_trailing("/_area.toml", "")
    |> InfoToml.get_items()
    |> Enum.filter(filter_fn)
    |> Enum.sort_by(sort_fn)
  end

  @spec reload_h(Plug.Conn.t(), any) :: Plug.Conn.t() #W

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

  @spec show_h(Plug.Conn.t(), integer, String.t) :: Plug.Conn.t() #W

  defp show_h(conn, 1, key) do
  #
  # Summarize the site's areas at level 1 (`Areas`).

    item  = InfoToml.get_item(key)

    reduce_fn = fn (x, acc) ->
      tuple = { x, get_areas(x) }
      [ tuple | acc ]
    end

    tuples  = get_areas()
    |> Enum.reduce([], reduce_fn)
    |> Enum.reverse()

    conn
    |> assign(:item,        item)
    |> assign(:key,         key)
    |> assign(:page_type,   :area_1)
    |> assign(:title,       "PA Areas")
    |> assign(:tuples,      tuples)
    |> render("show_1.html")
  end

  defp show_h(conn, 2, key) do
  #
  # Summarize the site's areas at level 2 (eg, `Areas/Content`).

    item      = InfoToml.get_item(key)
    patt      = ~r{ ^ [^/]+ / [^/]+ / ( [^/]+ ) / .+ $ }x

    if item == nil do
      key_ng(conn, key)
    else
      reduce_fn = fn {path, _title, _precis}, acc ->
        section   = String.replace(path, patt, "\\1")

        Map.update(acc, section, 1, &(&1 + 1) )
      end

      counts  = key
      |> get_items()
      |> Enum.reduce(%{}, reduce_fn)

      name      = get_area_name(key)
      sections  = get_areas(name)

      conn
      |> assign(:counts,      counts)
      |> assign(:item,        item)
      |> assign(:key,         key)
      |> assign(:name,        name)
      |> assign(:page_type,   :area_2)
      |> assign(:sections,    sections)
      |> assign(:title,       "PA Areas")
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

  @spec show_h3(Plug.Conn.t(), String.t, String.t, item_map) :: Plug.Conn.t() #W

  defp show_h3(conn, name, key, item) do
  #
  # Help out show_h/3 at level 3.

    real_items  = get_items(key)
    item_cnt    = Enum.count(real_items)

    map_fn1     = fn {_, title, _} ->
      title
      |> String.first()
      |> String.upcase()
    end

    map_fn2     = fn ltr -> {nil, ltr, nil} end

    first_chars = real_items
    |> Enum.map(map_fn1)
    |> Enum.sort()
    |> Enum.uniq()

    fake_items  = first_chars |> Enum.map(map_fn2)

    sort_fn     = fn {_path, title, _precis} -> String.downcase(title) end
    sort_items  = (fake_items ++ real_items) |> Enum.sort_by(sort_fn)

    conn
    |> assign(:first_chars,   first_chars)
    |> assign(:item,          item)
    |> assign(:item_cnt,      item_cnt)
    |> assign(:key,           key)
    |> assign(:name,          name)
    |> assign(:page_type,     :area_3)
    |> assign(:sort_items,    sort_items)
    |> assign(:title,         "PA Areas")
    |> render("show_3.html")
  end

end
