defmodule TokenManager.Commands.ClearExpiredTokens do
  @moduledoc """
    Command module to clear expired tokens by releasing them back to available status.
  """

  import Ecto.Query

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token

  require Logger

  @spec execute() :: :ok
  def execute do
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
