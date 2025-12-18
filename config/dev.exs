import Config

# Configure your database
config :token_manager, TokenManager.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "token_manager_dev",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :token_manager, TokenManagerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "Hpr0IFnWPbzdIvBVYwi9DJOz/4lnzPBa6qQPXV9PRAYWDxlkhxSEnpw5WwLYo34V",
  watchers: []

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime
