defmodule TokenManagerWeb.TokenController do
  use Phoenix.Controller, formats: [:json]

  alias TokenManager.Commands.AssignToken
  alias TokenManager.Commands.ClearAllTokens
  alias TokenManager.Commands.FetchTokenInfo
  alias TokenManager.Commands.ListTokens
  alias TokenManager.Commands.TokenHistory

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

  @spec list(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def list(conn, params) do
    filter = %ListTokens{
      status: params["status"] || nil,
      user_id: params["user_id"] || nil,
      expires_before: parse_datetime(params["expires_before"])
    }

    tokens = ListTokens.list(filter)

    render(conn, :index, tokens: tokens)
  end

  @spec fetch_token(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def fetch_token(conn, %{"token_id" => token_id}) do
    case FetchTokenInfo.fetch_token_info(token_id) do
      {:error, :token_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{error: "token_not_found"})

      {:error, _} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "internal_server_error"})

      token_info ->
        render(conn, :token_info, token_info)
    end
  end

  @spec token_history(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def token_history(conn, %{"token_id" => token_id}) do
    history = TokenHistory.token_history(token_id)
    render(conn, :token_history, history: history)
  end

  @spec clear_all_tokens(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def clear_all_tokens(conn, _params) do
    case ClearAllTokens.clear_all() do
      :ok ->
        conn
        |> put_status(:created)
        |> json(%{})

      :error ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "internal_server_error"})
    end
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
