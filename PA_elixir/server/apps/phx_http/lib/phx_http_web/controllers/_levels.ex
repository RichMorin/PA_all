# controllers/_levels.ex

defmodule PhxHttpWeb.Cont.Levels do
#
# Public functions
#
#   show_h/3
#    Summarize the site's areas at various levels (mostly 1-3).
#
# Private functions
#
#   get_tidy_tuples/1
#     Get a list of item tuples, sorted (by title) and filtered.
#   show_h3/4
#     Help out show_h/3 at level 3.

  @moduledoc """
  This module generates HTML content to display different Area levels.
  """

  import Common, only: [ sort_by_elem: 3 ]
  import InfoToml,
    only: [ get_area_name: 1, get_area_names: 0, get_area_names: 1 ]
  import Phoenix.Controller, only: [ render: 2 ]
  import PhxHttpWeb.Cont.Zoo
  import Plug.Conn

  alias InfoToml.Types, as: ITT

  # Public functions

  @spec show_h(pc, 1..3, String.t) :: pc
    when pc: Plug.Conn.t

  @doc """
  Summarize the site's areas at various levels.
  """

  def show_h(conn, 1, key) do
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

  def show_h(conn, 2, key) do
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

  def show_h(conn, 3, key) do
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

  def show_h(conn, _, key), do: key_ng(conn, key)
  #
  # Handle bogus levels.

  # Private Functions

  @spec get_tidy_tuples(String.t) :: [ITT.item_tuple]

  defp get_tidy_tuples(key) do
  #
  # Get a list of item tuples, sorted (by title) and filtered.

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

  @spec show_h3(pc, st, st, ITT.item_map) :: pc
    when pc: Plug.Conn.t, st: String.t

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
