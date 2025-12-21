defmodule TokenManager.Commands.ClearAllTokens do
  @moduledoc """
    Command module to clear all tokens in the system.
  """

  import Ecto.Query, warn: false

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token

  @spec clear_all() :: :ok
  def clear_all do
    from(t in Token)
    |> Repo.update_all(set: [status: "available", user_id: nil, expires_at: nil])
    |> case do
      {count, _} when is_integer(count) -> :ok
      _ -> :error
    end
  end
end
