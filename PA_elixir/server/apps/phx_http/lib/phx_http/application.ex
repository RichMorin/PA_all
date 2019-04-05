defmodule PhxHttp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

# @spec - WIP

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      PhxHttpWeb.Endpoint
      # Starts a worker by calling: PhxHttp.Worker.start_link(arg)
      # {PhxHttp.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhxHttp.Supervisor]
    Supervisor.start_link(children, opts)
  end

# @spec - WIP

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PhxHttpWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
