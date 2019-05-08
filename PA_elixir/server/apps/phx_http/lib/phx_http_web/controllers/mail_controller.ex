# controllers/mail_controller.ex

defmodule PhxHttpWeb.MailController do
#
# Public functions
#
#   feed_form/2
#     Generate the mail composing and sending page.
#   feed_post/2
#     Send the feedback, then redisplay the page.

  @moduledoc """
  This module contains controller actions (etc) for editing and sending email.
  """

  use InfoToml.Types
  use PhxHttp.Types
  use PhxHttpWeb, :controller

  # Public functions

  @doc """
  This function generates the feedback composing and sending page.
  """

  @spec feed_form(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def feed_form(conn, params) do

    prev_url  = params["url"] || "???"

    conn
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :mail_edit)
    |> assign(:prev_url,        prev_url)
    |> assign(:title,           "PA Feedback")
    |> render("feed.html")
  end

  @doc """
  This function sends the feedback, then redisplays the page.
  """

  @spec feed_post(Plug.Conn.t(), any) :: Plug.Conn.t() #W

  def feed_post(conn, params) do

    feed_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_feed" #K
    feedback    = params["PA.message"]
    prev_url    = params["url"] || "???"

    feed_toml   = """
    [ feedback ]

      feedback    = '''
    #{ feedback }
      '''
    """

    save_path   = InfoToml.emit_toml(feed_base, ".feed", feed_toml)
    save_name   = String.replace(save_path, ~r{ ^ .+ / }x, "")

    message     = """
    Your feedback has been saved as "#{ save_name }".
    Feel free to use this Feedback page as a new starting point.
    """

    conn
    |> put_flash(:info,         message)
    |> assign(:item,            nil)
    |> assign(:key,             nil)
    |> assign(:page_type,       :mail_edit)
    |> assign(:prev_url,        prev_url)
    |> assign(:title,           "PA Feedback")
    |> render("feed.html")
  end

  # Private functions

end
