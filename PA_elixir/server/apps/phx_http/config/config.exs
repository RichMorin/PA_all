# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration

use Mix.Config

# Configures the endpoint

config :phx_http, PhxHttpWeb.Endpoint,
  url:             [host: "localhost"],
  secret_key_base: "Cua4Ukgxd3SKgG34T2O/6ZkF8gLkXFqzxXXx4JM//JKN2tdH2UPHtgL4G8C9+f5e",
  render_errors:   [view: PhxHttpWeb.ErrorView, accepts: ~w(html json)],
  pubsub:          [name: PhxHttp.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger

config :logger, :console,
  format:   "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix

config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.

import_config "#{ Mix.env() }.exs"
