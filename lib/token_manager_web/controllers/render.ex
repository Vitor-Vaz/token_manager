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
        created_at: format_datetime(audit.inserted_at)
      }
    end)
  end

  def users(%{users: users}) do
    Enum.map(users, fn user ->
      %{
        id: user.id,
        inserted_at: format_datetime(user.inserted_at),
        updated_at: format_datetime(user.updated_at)
      }
    end)
  end

  defp data(%Token{} = token) do
    %{
      id: token.id,
      status: token.status,
      user_id: token.user_id,
      expires_at: format_datetime(token.expires_at),
      inserted_at: format_datetime(token.inserted_at),
      updated_at: format_datetime(token.updated_at)
    }
  end

  defp audit_data(audit) do
    %{
      user_id: audit.user_id,
      created_at: format_datetime(audit.inserted_at)
    }
  end

  defp format_datetime(%DateTime{} = datetime) do
    datetime
    |> DateTime.add(-3, :hour)
    |> Calendar.strftime("%d/%m/%Y %H:%M:%S")
  end

  defp format_datetime(%NaiveDateTime{} = naive_datetime) do
    naive_datetime
    |> DateTime.from_naive!("Etc/UTC")
    |> format_datetime()
  end

  defp format_datetime(_), do: nil
end
