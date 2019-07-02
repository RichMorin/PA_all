# controllers/item_controller.ex

defmodule PhxHttpWeb.ItemController do
#
# Public functions
#
#   get_gi_bases/1
#     Get a sorted, unique list of "base paths" from the `gi_pairs` list.
#   get_gi_pairs/1
#     Get a list of `{gi_path, value}` pairs.
#   get_item_map/2
#     Generate an "item map", based on `gi_bases` and `gi_pairs`.
#   show/2
#     Display a specified item.
#
# Private functions
#
#   get_gi_path/1
#     Get a `gi_path`, based on a `dot_path`
#   get_make/1
#     Get any `make.toml` information.
#   show_h/2
#     Handle item requests, with and without a key.
#   show_h2/2
#     Fold some `make.toml` info into the item.
#   show_h3/4
#     Gather up some `make.toml` info.

  @moduledoc """
  This module contains controller actions (etc) for displaying specified
  items in the "Areas/..." portion of the `toml_map`.
  """

  use PhxHttpWeb, :controller

  import Common, only: [ sort_by_elem: 2 ]

  # Public functions

  @doc """
  Get a sorted, unique list of "base paths" from the `gi_pairs` list.
  (This is used by `get_item_map/2` to pre-populate interior map nodes.)
  """

  @spec get_gi_bases([ {} ]) :: [ [atom] ] #W

  def get_gi_bases(gi_pairs) do

    bases_fn  = fn
    #
    # Return a list of gi_base lists.
    #
    #K Handles only three levels of maps.

      { [a, _],       _val }  -> [ [a] ]
      { [a, b, _],    _val }  -> [ [a], [a, b] ]
      { [a, b, c, _], _val }  -> [ [a], [a, b], [a, b, c] ]
    end

    gi_pairs                      # [ { [:a, :b, :c], "42" }, ... ]
    |> Enum.map(bases_fn)         # [ [[:a]], [[:a, :b]], ... ]
    |> Enum.concat()              # [ [:a], [:a, :b], ... ]
    |> Enum.sort()                # ditto, but sorted
    |> Enum.uniq()                # ditto, but unique
#   |> ii("gi_bases") #T
  end

  @doc """
  Get a list of `{gi_path, value}` pairs, where `gi_path`
  is an access path list, as used by `get_in/2`.
  """

  @spec get_gi_pairs(any) :: [ { [atom], String.t } ] #W

  def get_gi_pairs(params) do

    prefix      = ~r{ ^ PA \. }x

    filter_fn   = fn {key,  val} -> key =~ prefix && val != "" end
    #
    # Return true for non-empty "PA.*" params.

    tuple_fn    = fn {key, val} ->
    #
    # Return a tuple, composed of a gi_path and an id_str.

      gi_path = key                     # "PA.meta.id_str"
      |> String.replace(prefix, "")     # "meta.id_str"
      |> get_gi_path()                  # [ :meta, :id_str ]

      {gi_path, val}                    # { [ :meta, :id_str ], "Alot" }
    end

    params                        # [ { "PA.meta.id_str", "Alot" }, ... ]
    |> Enum.filter(filter_fn)     # keep only non-empty "PA.*" params
    |> Enum.map(tuple_fn)         # [ { [:meta, :id_str], "Alot" }, ... ]
    |> sort_by_elem(0)            # sort by gi_path, eg: [:meta, :id_str]
#   |> ii("gi_pairs") #T
  end

  @doc """
  Generate an "item map", based on:

  - `gi_bases` - a list of interior (i.e., base) `gi_path` lists
  - `gi_pairs` - a list of key/value tuples, e.g.: `{gi_path, val}`
  """

  @spec get_item_map([ [atom] ], [ {} ]) :: map #W

  def get_item_map(gi_bases, gi_pairs) do
  #
  # ToDo: Detect and handle wonky (non-UTF8) characters.

    # Create the interior nodes.

    base_fn   = fn gi_list, acc -> put_in(acc, gi_list, %{}) end
    #
    # Create the base map.

    base_map    = gi_bases            # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(%{}, base_fn)      # %{ meta: %{}, ... }
#   |> ii("base_map") #T

    # Fold in the exterior nodes.

    augment_fn  = fn {gi_list, val}, acc -> put_in(acc, gi_list, val) end
    #
    # Augment the base map with exterior nodes.

    gi_pairs                              # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(base_map, augment_fn)  # %{ meta: %{ id_str: <value> }, ... }
#   |> ii("item_map") #T
  end

  @doc """
  This function displays a specified item.
  """

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show(conn, params) do
    key   = params["key"]

    show_h(conn, key)
  end

  # Private Functions

  @spec get_gi_path(String.t) :: [atom] #W

  defp get_gi_path(dot_path) do
  #
  # Get a `gi_path` (an access path list, as used by `get_in/2`),
  # based on a `dot_path` (a dot-separated list of names), eg:
  #
  #   "foo.bar.baz" -> `[:foo, :bar, :baz]`.

    dot_path                          # "foo.bar.baz"
    |> String.split(".")              # [ "foo", "bar", "baz" ]
    |> Enum.map(&String.to_atom/1)    # [ :foo, :bar, :baz ]
#   |> ii("gi_path") #T
  end

  @spec get_make(String.t) :: map | nil #W

  defp get_make(key) do
  #
  # Get any some `make.toml` information.

    make_key  = key
    |> String.replace_suffix("/main.toml", "/make.toml")

    InfoToml.get_item(make_key)
  end

  @spec get_reviews(String.t) :: [ String.t ] #W

  defp get_reviews(key) do
  #
  # Get a list of keys for review items.

    review_fn   = fn {path, _title, _precis} ->
    #
    # Return true for review items.

      text_patt   = ~r{ / text \. \w+ \. toml $ }x
      String.match?(path, text_patt)
    end

    key
    |> String.replace_trailing("/main.toml", "/")
    |> InfoToml.get_item_tuples()
    |> Enum.filter(review_fn)
    |> sort_by_elem(0)
    |> Enum.map(fn x -> elem(x, 0) end)
  end

  @spec show_h(Plug.Conn.t(), nil) :: Plug.Conn.t() #W

  defp show_h(conn, nil) do
  #
  # Handle requests with no key.

    message = "No key was specified for the item."
    nastygram(conn, message)
  end

  @spec show_h(Plug.Conn.t(), String.t) :: Plug.Conn.t() #W

  defp show_h(conn, key) do
  #
  # Handle requests that have a key.  If the key doesn't match an item,
  # redirect to the most appropriate Area page.

    item    = InfoToml.get_item(key)

    if item == nil do
      message   = "Sorry, I don't recognize that item. " <>
                  "Please examine this Area page for alternatives."

      conn
      |> put_flash(:error, message)
      |> redirect(to: "/area?key=#{ InfoToml.get_area_key(key) }")
    else
      item      = show_h2(item, key)
      reviews   = get_reviews(key)

      conn
      |> base_assigns(:item, "PA Item", item, key)
      |> assign(:reviews,     reviews)
      |> render("show.html")
    end
  end

  @spec show_h2(map, String.t) :: map #W

  defp show_h2(item, key) do
  #
  # Fold some `make.toml` info into the item.

    make_item   = get_make(key)

    if make_item == nil do
      item
    else
      arch_pi   = ~w(os arch package)a
      arch_po   = ~w(address related arch)a

      deb_pi    = ~w(os debian package)a
      deb_po    = ~w(address related debian)a

      item
      |> show_h3(make_item, arch_pi, arch_po)
      |> show_h3(make_item, deb_pi,  deb_po)
    end
  end

  @spec show_h3(map, map, [atom], [atom]) :: map #W

  defp show_h3(item, make_item, path_inp, path_out) do
  #
  # Gather up some `make.toml` info.

    value   = get_in(make_item, path_inp)

    if value do
      gi_path   = ~w(address related)a
      item      = if get_in(item, gi_path) do
        item
      else
        put_in(item, gi_path, %{})
      end

      put_in(item, path_out, value)
    else
      item
    end
  end

end
