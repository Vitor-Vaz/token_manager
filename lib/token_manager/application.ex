defmodule TokenManager.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TokenManagerWeb.Telemetry,
      TokenManager.Repo,
      TokenManager.TokenScheduler,
      TokenManagerWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: TokenManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    TokenManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
