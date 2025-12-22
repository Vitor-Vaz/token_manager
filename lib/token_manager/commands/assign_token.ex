defmodule TokenManager.Commands.AssignToken do
  @moduledoc """
  Module responsible for assigning tokens to users.
  """

  import Ecto.Query, warn: false

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.TokenAudits
  alias TokenManager.Schemas.User

  @doc """
  Assigns an available token to a user by updating the token's status to "active",
  setting the user_id, and defining an expiration time 2 minutes from the current time.

  ## Parameters
    - user_id: The UUID of the user to whom the token will be assigned.

  ## Returns
    - A map containing the assigned token's ID and the user ID on success.
    - An error tuple {:error, reason} if the assignment fails.
  """
  @spec assign_token(Ecto.UUID.t()) :: map() | {:error, atom()}
  def assign_token(user_id) do
    Repo.transaction(fn ->
      with %User{} <- Repo.get(User, user_id),
           nil <- fetch_user_active_token(user_id),
           %Token{} = token <- fetch_assignable_token_with_lock(),
           {:ok, _} <- do_activation_token(token, user_id),
           :ok <- register_token_audit(token.id, user_id) do
        %{token_id: token.id, user_id: user_id}
      else
        %Token{} = token ->
          %{token_id: token.id, user_id: user_id}

        nil ->
          Repo.rollback(:user_not_found)

        {:error, reason} ->
          Repo.rollback(reason)

        _ ->
          Repo.rollback(:unexpected_error)
      end
    end)
    |> case do
      {:ok, result} -> result
      {:error, reason} -> {:error, reason}
    end
  end

  defp fetch_assignable_token_with_lock do
    from(t in Token, where: t.status == "available", limit: 1, lock: "FOR UPDATE")
    |> Repo.one()
    |> case do
      nil -> fetch_last_active_token_with_lock()
      token -> token
    end
  end

  defp fetch_user_active_token(user_id) do
    from(t in Token, where: t.status == "active" and t.user_id == ^user_id)
    |> Repo.one()
  end

  defp fetch_last_active_token_with_lock do
    from(t in Token,
      where: t.status == "active",
      limit: 1,
      order_by: [asc: t.expires_at],
      lock: "FOR UPDATE"
    )
    |> Repo.one()
    |> case do
      %Token{} = token ->
        token

      _ ->
        {:error, :failed_to_fetch_last_active_token}
    end
  end

  defp do_activation_token(token, user_id) do
    token
    |> Token.changeset(%{
      status: "active",
      user_id: user_id,
      expires_at: DateTime.add(DateTime.utc_now(), 120, :second)
    })
    |> Repo.update()
    |> case do
      {:ok, updated_token} -> {:ok, updated_token}
      {:error, reason} -> {:error, reason}
    end
  end

  defp register_token_audit(token_id, user_id) do
    %TokenAudits{}
    |> TokenAudits.changeset(%{token_id: token_id, user_id: user_id})
    |> Repo.insert()
    |> case do
      {:ok, _} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
