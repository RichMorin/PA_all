# controllers/item_controller.ex

defmodule PhxHttpWeb.ItemController do
#
# Public functions
#
#   edit_form/2
#     Generate the edit_form page.
#   edit_post/2
#     Handle the edit_post action.
#   show/2
#     Display a specified item.
#
# Private functions
#
#   get_gi_bases/1
#     Get a sorted, unique list of "base paths" from the `gi_pairs` list.
#   get_gi_pairs/1
#     Get a list of `{gi_path, value}` pairs.
#   get_gi_path/1
#     Get a `gi_path`, based on a `dot_path`
#   get_item_map/2
#     Generate an "item map", based on `gi_bases` and `gi_pairs`.
#   get_make/1
#     Get any `make.toml` information.
#   show_h/2
#     Handle item requests, with and without a key.
#   show_h2/2
#     Fold some `make.toml` info into the item.

  @moduledoc """
  This module contains controller actions (etc) for displaying specified
  items in the "Areas/..." portion of the `toml_map`.
  """

  use InfoToml, :common
  use InfoToml.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  @doc """
  This function generates the `edit_form` page.
  """

  @spec edit_form(conn, params) :: conn

  def edit_form(conn, params) do
    schema    = "_schemas/main.toml" |> InfoToml.get_item()
    key       = params["key"]
    item      = InfoToml.get_item(key)

    conn  = if (key != nil) && (item == nil) do
      message = "Sorry, the specified key (#{ key }) was not found, " <>
                "so no data was loaded."
      put_flash(conn, :error, message) 
    else
      conn
    end

    conn
    |> assign(:item,        item)
    |> assign(:key,         key)
    |> assign(:page_type,   :edit_f)
    |> assign(:schema,      schema)
    |> assign(:title,       "PA Edit")
    |> render("edit.html")
  end

  @doc """
  This function handles the `edit_post` action.
  """

  @spec edit_post(conn, params) :: conn

  def edit_post(conn, params) do

    gi_pairs    = get_gi_pairs(params)
    gi_bases    = get_gi_bases(gi_pairs)
    item_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_items" #K
    item_key    = params["key"]
    item_map    = get_item_map(gi_bases, gi_pairs)
    item_toml   = InfoToml.get_item_toml(gi_bases, item_map)
#   item        = InfoToml.get_item(item_key)
    schema      = "_schemas/main.toml" |> InfoToml.get_item()

    case params["button"] do
      "Preview" ->
        conn
        |> assign(:item,        item_map)
        |> assign(:item_toml,   item_toml)
        |> assign(:key,         item_key)
        |> assign(:page_type,   :edit_p)
        |> assign(:schema,      schema)
        |> assign(:title,       "PA Edit")
        |> render("preview.html")

      "Submit" ->
        save_path = InfoToml.emit_toml(item_base, item_toml)
        save_name = String.replace(save_path, ~r{ ^ .+ / }x, "")
        message   = """
        Your submission has been saved as "#{ save_name }".
        Feel free to use this Edit page as a new starting point.
        """

        conn
        |> put_flash(:info,     message)
        |> assign(:item,        item_map)
        |> assign(:key,         item_key)
        |> assign(:page_type,   :edit_s)
        |> assign(:schema,      schema)
        |> assign(:title,       "PA Edit")
        |> render("edit.html")
    end
  end

  @doc """
  This function displays a specified item.
  """

  @spec show(conn, params) :: conn

  def show(conn, params) do
    key    = params["key"]

    show_h(conn, key)
  end

  # Private Functions

# @spec get_gi_bases([ {} ]) :: [ [atom] ] #K

  defp get_gi_bases(gi_pairs) do
  #
  # Get a sorted, unique list of "base paths" from the `gi_pairs` list.
  # (This is used by `get_item_map/2` to pre-populate interior map nodes.)

    map_fn    = fn    #K Handles only three levels of maps.
      { [a, _],       _val }  -> [ [a] ]
      { [a, b, _],    _val }  -> [ [a], [a, b] ]
      { [a, b, c, _], _val }  -> [ [a], [a, b], [a, b, c] ]
    end

    gi_pairs                      # [ { [:a, :b, :c], "42" }, ... ]
    |> Enum.map(map_fn)           # [ [[:a]], [[:a, :b]], ... ]
    |> Enum.concat()              # [ [:a], [:a, :b], ... ]
    |> Enum.sort()                # ditto, but sorted
    |> Enum.uniq()                # ditto, but unique
#   |> ii("gi_bases") #T
  end

# @spec get_gi_pairs(map) :: [ {} ] #K

  defp get_gi_pairs(params) do
  #
  # Get a list of `{gi_path, value}` pairs, where `gi_path`
  # is an access path list, as used by `get_in/2`.

    prefix      = ~r{ ^ PA \. }x

    filter_fn   = fn {key,  val} -> key =~ prefix && val != "" end

    map_fn      = fn {key, val} ->
      gi_path = key                     # "PA.meta.id_str"
      |> String.replace(prefix, "")     # "meta.id_str"
      |> get_gi_path()                  # [ :meta, :id_str ]

      {gi_path, val}                    # { [ :meta, :id_str ], "Alot" }
    end

    sort_fn     = fn {gi_path, _val} -> gi_path end

    params                        # [ { "PA.meta.id_str", "Alot" }, ... ]
    |> Enum.filter(filter_fn)     # keep only non-empty "PA.*" params
    |> Enum.map(map_fn)           # [ { [:meta, :id_str], "Alot" }, ... ]
    |> Enum.sort_by(sort_fn)      # sort by gi_path, eg: [:meta, :id_str]
#   |> ii("gi_pairs") #T
  end

# @spec get_gi_path(String.t) :: [atom] #K

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

# @spec get_item_map([ [atom] ], [ {} ]) :: map #K

  def get_item_map(gi_bases, gi_pairs) do
  #
  # Generate an "item map", based on:
  # - `gi_bases` - a list of interior (ie, base) `gi_path` lists
  # - `gi_pairs` - a list of key/value tuples, eg: `{gi_path, val}`
  #
  # TODO: Detect and handle wonky (non-UTF8) characters.

    # Create the interior nodes.

    reduce_fn1  = fn gi_list, acc -> put_in(acc, gi_list, %{}) end

    base_map    = gi_bases            # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(%{}, reduce_fn1)   # %{ meta: %{}, ... }
#   |> ii("base_map") #T

    reduce_fn2  = fn {gi_list, val}, acc -> put_in(acc, gi_list, val) end

    # Fold in the exterior nodes.

    gi_pairs                              # [ { <gi_path>, <value> }, ... ]
    |> Enum.reduce(base_map, reduce_fn2)  # %{ meta: %{ id_str: <value> }, ... }
#   |> ii("item_map") #T
  end

  @spec get_make(String.t) :: map | nil

  defp get_make(key) do
  #
  # Get any some `make.toml` information.

    make_key    = key
    |> String.replace_suffix("/main.toml", "/make.toml")

    InfoToml.get_item(make_key)
  end

  @spec get_reviews(String.t) :: [ String.t ]

  defp get_reviews(key) do
  #
  # Get a list of keys for review items.

    filter_fn   = fn {path, _title, _precis} ->
      text_patt   = ~r{ / text \. \w+ \. toml $ }x
      String.match?(path, text_patt)
    end

    sort_fn     = fn {path, _title, _precis} -> path end

    key
    |> String.replace_trailing("/main.toml", "/")
    |> InfoToml.get_items()
    |> Enum.filter(filter_fn)
    |> Enum.sort_by(sort_fn)
    |> Enum.map(fn x -> elem(x,0) end)
  end

  @spec show_h(map, nil) :: map

  defp show_h(conn, nil) do
  #
  # Handle requests with no key.

    message = "No key was specified for the item."
    nastygram(conn, message)
  end

  @spec show_h(map, String.t) :: map

  defp show_h(conn, key) do
  #
  # Handle requests with a key.

    item   = InfoToml.get_item(key)

    if item == nil do
      key_ng(conn, key)
    else
      item      = show_h2(item, key)
      reviews   = get_reviews(key)

      conn
      |> assign(:item,        item)
      |> assign(:key,         key)
      |> assign(:page_type,   :item)
      |> assign(:reviews,     reviews)
      |> assign(:title,       "PA Item")
      |> render("show.html")
    end
  end

  @spec show_h2(map, String.t) :: map

  defp show_h2(item, key) do
  #
  # Fold some `make.toml` info into the item.

    make_item   = get_make(key)

    if make_item == nil do
      item
    else
      make_fn   = fn item, path_inp, path_out ->
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

      arch_pi   = ~w(os arch package)a
      arch_po   = ~w(address related arch)a

      deb_pi    = ~w(os debian package)a
      deb_po    = ~w(address related debian)a

      item
      |> make_fn.(arch_pi, arch_po)
      |> make_fn.(deb_pi,  deb_po)
    end
  end

end
