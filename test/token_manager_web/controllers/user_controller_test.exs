defmodule TokenManagerWeb.UserControllerTest do
  use TokenManagerWeb.ConnCase

  alias TokenManager.Repo
  alias TokenManager.Schemas.User

  describe "GET /api/users/:limit" do
    test "returns the specified number of users", %{conn: conn} do
      for _ <- 1..10 do
        Repo.insert!(%User{})
      end

      limit = 5

      response =
        conn
        |> get("/api/users/#{limit}")
        |> json_response(200)

      assert length(response) == limit
    end

    test "returns 10 users when limit is not a positive integer", %{conn: conn} do
      for _ <- 1..15 do
        Repo.insert!(%User{})
      end

      invalid_quantities = ["abc", "-5", "0"]

      for qty <- invalid_quantities do
        response =
          conn
          |> get("/api/users/#{qty}")
          |> json_response(200)

        assert length(response) == 10
      end
    end
  end
end
