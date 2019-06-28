# phx_http/application.ex

defmodule PhxHttp.Application do

  @moduledoc false

  use Application

  # Public functions

# @spec - ToDo

  def start(_type, _args) do
    # List all child processes to be supervised.
    children = [
      # Start the endpoint when the application starts.
      PhxHttpWeb.Endpoint
      # Starts a worker by calling: PhxHttp.Worker.start_link(arg)
      # {PhxHttp.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxHttp.Supervisor]
    Supervisor.start_link(children, opts)
  end

# @spec - ToDo

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhxHttpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
