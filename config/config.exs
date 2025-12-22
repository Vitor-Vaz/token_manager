import Config

config :token_manager,
  ecto_repos: [TokenManager.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :token_manager, TokenManagerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: TokenManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TokenManager.PubSub

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
