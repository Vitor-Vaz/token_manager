defmodule TokenManagerWeb.TokenControllerTest do
  use TokenManagerWeb.ConnCase

  alias TokenManager.Repo
  alias TokenManager.Schemas.User
  alias TokenManager.Schemas.Token

  describe "assign_token/2" do
    test "successfully assigns a token to a user", %{conn: conn} do
      user_id = Ecto.UUID.generate()

      user = Repo.insert!(%User{id: user_id})
      _token = Repo.insert!(%Token{status: "available"})

      response =
        conn
        |> post("/api/assign_token/#{user.id}")
        |> json_response(200)

      assert response["user_id"] == user_id

      assert Map.has_key?(response, "token_id")
    end

    test "returns error when user not found", %{conn: conn} do
      non_existent_user_id = Ecto.UUID.generate()

      assert %{"error" => "user_not_found"} ==
               conn
               |> post("/api/assign_token/#{non_existent_user_id}")
               |> json_response(404)
    end

    test "returns existing active token if user already has one", %{conn: conn} do
      user_id = Ecto.UUID.generate()

      user = Repo.insert!(%User{id: user_id})
      existing_token = Repo.insert!(%Token{status: "active", user_id: user_id})

      response =
        conn
        |> post("/api/assign_token/#{user.id}")
        |> json_response(200)

      assert response["token_id"] == existing_token.id
      assert response["user_id"] == user_id
    end

    test "fails when assignment token fails", %{conn: conn} do
      user_id = Ecto.UUID.generate()
      user = Repo.insert!(%User{id: user_id})

      assert %{"error" => "internal_server_error"} ==
               conn
               |> post("/api/assign_token/#{user.id}")
               |> json_response(500)
    end
  end
end
