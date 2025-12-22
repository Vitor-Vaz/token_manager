defmodule TokenManager.Workers.ReleaseExpiredTokens do
  @moduledoc """
  Worker module to release expired tokens back to available status.
  Runs periodically via Oban Cron Job to check for tokens past their expiration time.
  """

  use Oban.Worker, queue: :default

  import Ecto.Query

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token

  require Logger

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    now = DateTime.utc_now() |> DateTime.truncate(:second)

    from(t in Token,
      where: t.status == "active" and t.expires_at <= ^now
    )
    |> Repo.update_all(set: [status: "available", user_id: nil, expires_at: nil])
    |> case do
      {count, _} when count > 0 ->
        Logger.info("Released #{count} expired tokens back to available status.")
        :ok

      _ ->
        :ok
    end
  end
end
