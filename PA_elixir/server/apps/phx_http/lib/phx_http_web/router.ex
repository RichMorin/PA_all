defmodule PhxHttpWeb.Router do
  use PhxHttpWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :divider
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhxHttpWeb do
    pipe_through :browser

    get   "/area",            AreaController,     :show
    get   "/reload",          AreaController,     :reload

    get   "/dash",            DashController,     :show
    get   "/dash/code",       DashController,     :show_code
    get   "/dash/data",       DashController,     :show_data
    get   "/dash/make",       DashController,     :show_make
    get   "/dash/refs",       DashController,     :show_refs
    get   "/dash/tags",       DashController,     :show_tags

    get   "/item",            ItemController,     :show
    get   "/item/edit",       ItemController,     :edit_form
    post  "/item/edit",       ItemController,     :edit_post

    get   "/mail/feed",       MailController,     :feed_form
    post  "/mail/feed",       MailController,     :feed_post

    get   "/search/find",     SearchController,   :find
    post  "/search/show",     SearchController,   :show
    get   "/search/clear",    SearchController,   :clear_form
    post  "/search/clear",    SearchController,   :clear_post

    get   "/source",          SourceController,   :show
    get   "/source/down",     SourceController,   :down

    get   "/",                TextController,     :show
    get   "/text",            TextController,     :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhxHttpWeb do
  #   pipe_through :api
  # end

  @doc """
  When the server is running in :dev mode, this function displays a time-stamped
  divider (= = = ...) on the console for each request.
  """

  @spec divider(Plug.Conn.t(), any) :: Plug.Conn.t()

  def divider(conn, _opts) do # rdm
    if Common.run_mode() == :dev do #K
      prefix    = String.duplicate("= ", 5)
      iso8601   = DateTime.utc_now() |> DateTime.to_iso8601()

      IO.puts "\n#{ prefix }=> #{ iso8601 }\n"
    end

    conn
  end

end
