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

  use PhxHttpWeb, :controller

  import Common,
    only: [ get_http_port: 0, get_tree_base: 0, ii: 2, keyss: 1 ]

  alias PhxHttpWeb.Cont.Make

  # Public functions

  @doc """
  This function generates the Dashboard index page.
  """

  @spec show(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show(conn, _params) do

    conn
    |> base_assigns(:dashboard, "PA Dashboard")
    |> render("show.html")
  end

  @doc """
  This function generates the Dashboard display page for Code.
  """

  @spec show_code(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_code(conn, _params) do

    tree_base   = get_tree_base()

    code_info   = InfoFiles.get_code_info(tree_base)
    if code_info.tracing do #TG
      ii(keyss(code_info), "keyss(code_info)")
    end

    conn
    |> base_assigns(:dashboard, "PA Code")
    |> assign(:code_info, code_info)
    |> render("show_code.html")
  end

  @doc """
  This function generates the Dashboard display page for Data.
  """

  @spec show_data(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def show_data(conn, _params) do

    tree_base       = get_tree_base()

    data_info  = InfoFiles.get_data_info(tree_base)
    if data_info.tracing do #TG
      ii(keyss(data_info), "keyss(data_info)")
    end

    conn
    |> base_assigns(:dashboard, "PA Data")
    |> assign(:data_info, data_info)
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

    packages  = Make.packages()

    conn
    |> base_assigns(:dashboard, "PA Make")
    |> assign(:packages, packages)
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
    |> base_assigns(:dashboard, "PA Refs")
    |> assign(:data_info, data_info)
    |> assign(:ref_info,  ref_info)
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
    |> base_assigns(:dashboard, "PA Tags")
    |> assign(:data_info, data_info)
    |> assign(:tag_info,  tag_info)
    |> render("show_tags.html")
  end

  # Private functions

  @spec show_links_h(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  defp show_links_h(conn, _params) do

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
    |> base_assigns(:dashboard, "PA Links")
    |> assign(:link_info, link_info)
    |> render("show_links.html")
  end

end
