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

  use PhxHttpWeb, :controller

  alias PhxHttp.Types,  as: PHT

  # Public functions

  @doc """
  This function generates the feedback composing and sending page.
  """
  @spec feed_form(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def feed_form(conn, params) do

    prev_url  = params["url"] || "???"

    conn
    |> base_assigns(:mail_edit, "PA Feedback")
    |> assign(:prev_url,        prev_url)
    |> render("feed.html")
  end

  @doc """
  This function sends the feedback, then redisplays the page.
  """

  @spec feed_post(pc, PHT.params) :: pc
    when pc: Plug.Conn.t

  def feed_post(conn, params) do

    feed_base   = "/Local/Users/rdm/Dropbox/Rich_bench/PA_feed" #!K
    prev_url    = params["url"] || "???"

    feedback    = params["PA.message"]
    |> String.replace("\r\n", "\n")     # Fix CR/NL
    |> String.replace("\r",   "\n")     # Fix CR

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
    |> base_assigns(:mail_edit, "PA Feedback")
    |> assign(:prev_url,        prev_url)
    |> render("feed.html")
  end

  # Private functions

end
