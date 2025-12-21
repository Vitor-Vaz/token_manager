defmodule TokenManager.Commands.TokenHistory do
  @moduledoc """
    Command module to fetch the history users that have used a specific token.
  """

  import Ecto.Query

  alias TokenManager.Repo
  alias TokenManager.Schemas.TokenAudits

  @doc """
    Fetches the history of users that have used the specified token.
  """
  @spec token_history(Ecto.UUID.t()) :: list(TokenAudits.t())
  def token_history(token_id) do
    Repo.all(
      from(a in TokenAudits,
        where: a.token_id == ^token_id,
        order_by: [desc: a.inserted_at],
        limit: 10
      )
    )
  end
end
