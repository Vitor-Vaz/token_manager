defmodule TokenManagerWeb.TokenController do
  use Phoenix.Controller, formats: [:json]

  alias TokenManager.Commands.AssignToken
  alias TokenManager.Commands.ListTokens

  @spec assign_token(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def assign_token(conn, %{"user_id" => user_id}) do
    case AssignToken.assign_token(user_id) do
      %{token_id: token_id, user_id: user_id} ->
        json(conn, %{token_id: token_id, user_id: user_id})

      {:error, :user_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "user_not_found"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "internal_server_error"})
    end
  end

  def list(conn, params) do
    filter = %ListTokens{
      status: params["status"] || nil,
      user_id: params["user_id"] || nil,
      expires_before: parse_datetime(params["expires_before"])
    }

    tokens = ListTokens.list(filter)

    render(conn, :index, tokens: tokens)
  end

  defp parse_datetime(nil), do: nil

  defp parse_datetime(datetime_string) when is_binary(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, datetime, _} -> datetime
      _ -> nil
    end
  end

  defp parse_datetime(datetime), do: datetime
end
