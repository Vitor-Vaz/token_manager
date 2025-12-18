import Config

config :token_manager,
  ecto_repos: [TokenManager.Repo],
  generators: [timestamp_type: :utc_datetime]

config :phoenix_live_view,
  enable_expensive_runtime_checks: true

# Configure the endpoint
config :token_manager, TokenManagerWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TokenManagerWeb.ErrorHTML, json: TokenManagerWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TokenManager.PubSub,
  live_view: [signing_salt: "RBA5EK9q"]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
