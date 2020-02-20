# phx_http_web/router.ex

defmodule PhxHttpWeb.Router do

  @moduledoc """
  This module handles the routing from URLs to controllers.
  """

  use PhxHttpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers

    plug PhxHttpWeb.Plugs.Bar
    plug PhxHttpWeb.Plugs.TOC
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhxHttpWeb do
    pipe_through :browser

    get   "/area",            AreaController,     :show
    get   "/reload",          AreaController,     :reload

    get   "/clear",           ClearController,    :clear_form
    post  "/clear",           ClearController,    :clear_post

    get   "/dash",            DashController,     :show
    get   "/dash/code",       DashController,     :show_code
    get   "/dash/data",       DashController,     :show_data
    get   "/dash/links",      DashController,     :show_links
    get   "/dash/make",       DashController,     :show_make
    get   "/dash/refs",       DashController,     :show_refs
    get   "/dash/tags",       DashController,     :show_tags

    get   "/edit",            EditController,     :edit_form
    post  "/edit",            EditController,     :edit_post

    get   "/item",            ItemController,     :show

    get   "/mail/feed",       MailController,     :feed_form
    post  "/mail/feed",       MailController,     :feed_post

    get   "/memo",            MemoController,     :show

    get   "/search/find",     SearchController,   :find
    post  "/search/show",     SearchController,   :show

    get   "/slide",           SlideController,    :show

    get   "/source",          SourceController,   :show
    get   "/source/down",     SourceController,   :down

    get   "/",                TextController,     :show
    get   "/text",            TextController,     :show

    get   "/*zoo",            ZooController,      :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxHttpWeb do
  #   pipe_through :api
  # end

end
