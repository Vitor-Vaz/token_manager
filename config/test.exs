import Config

config :token_manager, TokenManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "token_manager_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

config :token_manager, TokenManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "qyrPtY3nMziqFVqcP1SUNkYDQr3j5luVto/Ab6+LDIdTzDMoYQlkXbR6UiwQ7dcr",
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime

config :phoenix,
  sort_verified_routes_query_params: true
