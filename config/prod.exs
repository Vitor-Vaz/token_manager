import Config

config :token_manager, TokenManagerWeb.Endpoint,
  cache_static_manifest: "priv/static/cache_manifest.json"

config :token_manager, TokenManagerWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  exclude: [
    # paths: ["/health"],
    hosts: ["localhost", "127.0.0.1"]
  ]

# Do not print debug messages in production
config :logger, level: :info
