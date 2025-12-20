defmodule TokenManager.Commands.FetchTokenInfo do
  @moduledoc """
    Command module to fetch detailed information about a specific token.
  """

  import Ecto.Query

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.TokenAudits
  alias TokenManager.Schemas.User

  @doc """
    Fetches detailed information about a specific token, including its associated user (if active)
    and the last 10 audit records related to that token.

    ## Parameters
      - token_id: The UUID of the token to fetch information for.

    ## Returns
      - A map containing the token, associated user (if any), and a list of audit records on success.
      - An error tuple {:error, reason} if the token is not found or another error occurs.
  """
  @spec fetch_token_info(any()) ::
          %{audits: list(TokenAudits.t()), token: Token.t(), user: User.t() | nil}
          | {:error, atom()}
  def fetch_token_info(token_id) do
    with {:token, %Token{} = token} <- {:token, Repo.get(Token, token_id)},
         user <- fetch_token_user(token),
         audits <- fetch_token_audits(token_id) do
      %{
        token: token,
        user: user,
        audits: audits
      }
    else
      {:token, nil} ->
        {:error, :token_not_found}

      _ ->
        {:error, :unexpected_error}
    end
  end

  defp fetch_token_user(%Token{user_id: user_id, status: "active"}) do
    Repo.get(User, user_id)
  end

  defp fetch_token_user(_), do: nil

  defp fetch_token_audits(token_id) do
    Repo.all(
      from(a in TokenAudits,
        where: a.token_id == ^token_id,
        order_by: [desc: a.inserted_at],
        limit: 10
      )
    )
  end
end
