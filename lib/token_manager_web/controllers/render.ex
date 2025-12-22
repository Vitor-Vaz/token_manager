defmodule TokenManagerWeb.RenderJSON do
  @moduledoc """
  JSON rendering all related to tokens.
  """

  alias TokenManager.Schemas.Token

  @doc """
  Renders a list of tokens.
  """
  def index(%{tokens: tokens}) do
    Enum.map(tokens, &data/1)
  end

  @doc """
  Renders detailed token information including audits and associated user.
  """
  def token_info(%{token: token, audits: audits}) do
    token
    |> data()
    |> Map.merge(%{
      users_history: Enum.map(audits, &audit_data/1)
    })
  end

  @doc """
  Renders the token history.
  """
  def token_history(%{history: history}) do
    Enum.map(history, fn audit ->
      %{
        user_id: audit.user_id,
        created_at: audit.inserted_at
      }
    end)
  end

  def users(%{users: users}) do
    Enum.map(users, fn user ->
      %{
        id: user.id,
        inserted_at: user.inserted_at,
        updated_at: user.updated_at
      }
    end)
  end

  defp data(%Token{} = token) do
    %{
      id: token.id,
      status: token.status,
      user_id: token.user_id,
      expires_at: token.expires_at,
      inserted_at: token.inserted_at,
      updated_at: token.updated_at
    }
  end

  defp audit_data(audit) do
    %{
      user_id: audit.user_id,
      created_at: audit.inserted_at
    }
  end
end
