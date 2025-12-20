defmodule TokenManager.Commands.ListTokens do
  @moduledoc """
    Command module to list all tokens in the system.
  """

  import Ecto.Query, warn: false

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token

  defstruct status: nil, user_id: nil, expires_before: nil

  @type t :: %__MODULE__{
          status: String.t() | nil,
          user_id: Ecto.UUID.t() | nil,
          expires_before: DateTime.t() | nil
        }

  @spec list(t()) :: list(Token.t())
  def list(filter) do
    from(t in Token)
    |> filter_by_status(filter.status)
    |> filter_by_user_id(filter.user_id)
    |> filter_by_expires_before(filter.expires_before)
    |> Repo.all()
  end

  defp filter_by_status(query, status) when status in ["available", "active"] do
    from(t in query, where: t.status == ^status)
  end

  defp filter_by_status(query, _), do: query

  defp filter_by_user_id(query, user_id) when is_binary(user_id) do
    from(t in query, where: t.user_id == ^user_id)
  end

  defp filter_by_user_id(query, _), do: query

  defp filter_by_expires_before(query, expires_before) when not is_nil(expires_before) do
    from(t in query, where: t.expires_at < ^expires_before)
  end

  defp filter_by_expires_before(query, nil), do: query
end
