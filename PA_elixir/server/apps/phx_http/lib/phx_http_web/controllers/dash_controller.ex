# controllers/dash_controller.ex

defmodule PhxHttpWeb.DashController do
#
# Public functions
#
#   show/2
#     Generate the Dashboard index page.
#   show_code/2
#     Generate the Dashboard display page for code files.
#   show_data/2
#     Generate the Dashboard display page for data files.
#   show_links/2
#     Generate the Dashboard display page for Links (maybe).
#   show_make/2
#     Generate the Dashboard display page for Make.
#   show_refs/2
#     Generate the Dashboard display page for Refs.
#   show_tags/2
#     Generate the Dashboard display page for Tags.
#
# Private functions
#
#   show_links_h/2
#     Generate the Dashboard display page for Links (really).

  @moduledoc """
  This module contains controller actions (etc) for printing the dashboards.
  """

  use InfoToml, :common
  use InfoToml.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  @doc """
  This function generates the Dashboard index page.
  """

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show(conn, _params) do

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :dashboard)
    |> assign(:title,           "PA Dashboard")
    |> render("show.html")
  end

  @doc """
  This function generates the Dashboard display page for code files.
  """

  @spec show_code(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_code(conn, _params) do

    tree_base   = get_tree_base()

    code_info   = InfoFiles.get_code_info(tree_base)
    if code_info.tracing do #TG
      ii(keyss(code_info), "keyss(code_info)")
    end

    conn
    |> assign(:code_info,       code_info)
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :dashboard)
    |> assign(:title,           "PA Code")
    |> render("show_code.html")
  end

  @doc """
  This function generates the Dashboard display page for data files.
  """

  @spec show_data(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_data(conn, _params) do

    tree_base       = get_tree_base()

    data_info  = InfoFiles.get_data_info(tree_base)
    if data_info.tracing do #TG
      ii(keyss(data_info), "keyss(data_info)")
    end

    conn
    |> assign(:data_info,       data_info)
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :dashboard)
    |> assign(:title,           "PA Data")
    |> render("show_data.html")
  end

  @doc """
  This function generates the Dashboard display page for Links.
  """

  @spec show_links(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_links(conn, params) do

    if get_http_port() == "4000" do #K
      show_links_h(conn, params)
    else
      message = "The Links dashboard is only supported for PORT 4000."
      nastygram(conn, message)
    end
  end

  @doc """
  This function generates the Dashboard display page for Make.
  """

  @spec show_make(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_make(conn, _params) do

    filter_fn1  = fn {key, _title, _precis} ->
      String.ends_with?(key, "/main.toml")
    end

    filter_fn2  = fn map ->
      make    = map.make

      make.main || make.arch || make.debian || make.other
    end

    map_fn      = fn {main_key, title, precis} ->

      main_data   = main_key |> InfoToml.get_item()

      make_data   = main_key
      |> String.replace_suffix("/main.toml", "/make.toml")
      |> InfoToml.get_item()

      make_fn     = fn os_key ->
        gi_path     = [ :os, os_key, :package ]
        get_in(make_data, gi_path) |> is_binary()
      end

      main_fn     = fn ->
        gi_path   = [ :meta, :actions ]

        get_in(main_data, gi_path)
        |> str_list()
        |> Enum.member?("build")
      end

      pattern   = ~r{ \s+ \( .* $ }x
      name      = main_data.meta.title
      |> String.replace(pattern, "")

      %{
        main:  %{  #D
          key:      main_key,
          precis:   precis,
          title:    title,
        },

        make:  %{  #D
          arch:     make_fn.(:arch),
          debian:   make_fn.(:debian),
          main:     main_fn.(),
          name:     name,
          other:    make_fn.(:zoo),
        }
      }
    end

    reduce_fn   = fn inp_map, acc ->
      name    = inp_map.make.name
      Map.put(acc, name, inp_map)
    end

    packages  = "Areas/Catalog/Software/"
    |> InfoToml.get_items()         # [ {key, title, precis}, ... ]
    |> Enum.filter(filter_fn1)      # keep items with ".../main.toml" keys
    |> Enum.map(map_fn)             # [ { key, title, precis, map }, ... ]
    |> Enum.filter(filter_fn2)      # keep plausible items
    |> Enum.reduce(%{}, reduce_fn)

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:packages,        packages)
    |> assign(:page_type,       :dashboard)
    |> assign(:title,           "PA Make")
    |> render("show_make.html")
  end

  @doc """
  This function generates the Dashboard display page for Refs.
  """

  @spec show_refs(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_refs(conn, _params) do

    tree_base   = get_tree_base()

    data_info   = InfoFiles.get_data_info(tree_base)
    if data_info.tracing do #TG
      ii(keyss(data_info), "keyss(data_info)")
    end

    ref_info    = InfoToml.get_ref_info()
    if ref_info.tracing do #TG
      ii(keyss(ref_info), "keyss(ref_info)")
    end

    conn
    |> assign(:data_info,       data_info)
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :dashboard)
    |> assign(:ref_info,        ref_info)
    |> assign(:title,           "PA Refs")
    |> render("show_refs.html")
  end

  @doc """
  This function generates the Dashboard display page for Tags.
  """

  @spec show_tags(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_tags(conn, _params) do

    tree_base   = get_tree_base()

    data_info   = InfoFiles.get_data_info(tree_base)
    if data_info.tracing do #TG
      ii(keyss(data_info), "keyss(data_info)")
    end

    tag_info    = InfoToml.get_tag_info()
    if tag_info.tracing do #TG
      ii(keyss(tag_info), "keyss(tag_info)")
    end

    conn
    |> assign(:data_info,       data_info)
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :dashboard)
    |> assign(:tag_info,        tag_info)
    |> assign(:title,           "PA Tags")
    |> render("show_tags.html")
  end

  # Private functions

  @spec show_links_h(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_links_h(conn, _params) do

    link_info   = InfoWeb.get_snap()

    _snap = """
      Note: The keys and values are strings; the counts are integers.

      %{
        "bins" => %{
          "ext_ng" => [ [ "<url>", "<from>", "<status>" ], ... ],
          "int_ng" => [ [ "<url>", "<from>", "<status>" ], ... ]
        },
        "counts" => %{
          "ext" => %{ "<site>"  => <count>, ... },
          "int" => %{ "<route>" => <count>, ... }
        },
        "raw" => %{
          "ext_ok" => [ "<url>", ... ]
        }
      }
    """

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:link_info,       link_info)
    |> assign(:page_type,       :dashboard)
    |> assign(:title,           "PA Links")
    |> render("show_links.html")
  end

end
