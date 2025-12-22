defmodule TokenManagerWeb.UserController do
  use Phoenix.Controller, formats: [:json]

  alias TokenManager.Commands.GetUsers
  alias TokenManagerWeb.RenderJSON

  @spec get_users(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def get_users(conn, %{"limit" => limit_str}) do
    users =
      limit_str
      |> Integer.parse()
      |> case do
        {num, _} when num > 0 -> num
        _ -> 10
      end
      |> GetUsers.get()

    conn
    |> put_view(RenderJSON)
    |> render(:users, users: users)
  end
end
