defmodule TokenManagerWeb.TokenController do
  use Phoenix.Controller, formats: [:json]

  alias TokenManager.Commands.AssignToken

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
end
