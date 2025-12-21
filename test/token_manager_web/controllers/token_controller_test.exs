defmodule TokenManagerWeb.TokenControllerTest do
  use TokenManagerWeb.ConnCase

  alias TokenManager.Commands.AssignToken
  alias TokenManager.Repo
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.User

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

  describe "list/2" do
    test "lists all tokens without filters", %{conn: conn} do
      for _ <- 1..3 do
        Repo.insert!(%Token{status: "available"})
      end

      response =
        conn
        |> get("/api/tokens")
        |> json_response(200)

      assert length(response) == 3
    end

    test "lists tokens filtered by status", %{conn: conn} do
      Repo.insert!(%Token{status: "available"})
      Repo.insert!(%Token{status: "active", user_id: Ecto.UUID.generate()})

      available_response =
        conn
        |> get("/api/tokens", %{"status" => "available"})
        |> json_response(200)

      active_response =
        conn
        |> get("/api/tokens", %{"status" => "active"})
        |> json_response(200)

      assert length(available_response) == 1
      assert Enum.all?(available_response, fn t -> t["status"] == "available" end)

      assert length(active_response) == 1
      assert Enum.all?(active_response, fn t -> t["status"] == "active" end)
    end

    test "lists tokens filtered by user_id", %{conn: conn} do
      user_id = Ecto.UUID.generate()
      Repo.insert!(%Token{status: "active", user_id: user_id})
      Repo.insert!(%Token{status: "available"})

      response =
        conn
        |> get("/api/tokens", %{"user_id" => user_id})
        |> json_response(200)

      assert length(response) == 1
      assert Enum.all?(response, fn t -> t["user_id"] == user_id end)
    end

    test "lists tokens filtered by expires_before", %{conn: conn} do
      now = DateTime.utc_now()

      past_time = now |> DateTime.add(30, :second) |> DateTime.truncate(:second)
      expires_before_time = now |> DateTime.add(60, :second) |> DateTime.truncate(:second)
      future_time = now |> DateTime.add(120, :second) |> DateTime.truncate(:second)

      Repo.insert!(%Token{status: "active", expires_at: nil})
      Repo.insert!(%Token{status: "active", expires_at: past_time})
      Repo.insert!(%Token{status: "active", expires_at: future_time})

      response =
        conn
        |> get("/api/tokens", %{"expires_before" => DateTime.to_iso8601(expires_before_time)})
        |> json_response(200)

      assert length(response) == 1

      assert Enum.all?(response, fn t ->
               {:ok, expires_at, _} = DateTime.from_iso8601(t["expires_at"])
               DateTime.compare(expires_at, expires_before_time) == :lt
             end)
    end

    test "list nothing when no tokens match filters", %{conn: conn} do
      user_id = Ecto.UUID.generate()

      response =
        conn
        |> get("/api/tokens", %{"status" => "active", "user_id" => user_id})
        |> json_response(200)

      assert Enum.empty?(response)
    end
  end

  describe "fetch_token/2" do
    test "successfully fetches token info", %{conn: conn} do
      token_id = Ecto.UUID.generate()
      Repo.insert!(%Token{id: token_id, status: "available"})

      response =
        conn
        |> get("/api/token/#{token_id}")
        |> json_response(200)

      assert %{
               "id" => ^token_id,
               "status" => "available",
               "expires_at" => nil,
               "user_id" => nil,
               "users_history" => []
             } = response
    end

    test "returns error when token not found", %{conn: conn} do
      non_existent_token_id = Ecto.UUID.generate()

      assert %{"error" => "token_not_found"} ==
               conn
               |> get("/api/token/#{non_existent_token_id}")
               |> json_response(404)
    end

    test "successfully fetches token info with audits", %{conn: conn} do
      token_id = Ecto.UUID.generate()
      user_id = Ecto.UUID.generate()

      Repo.insert!(%User{id: user_id})
      Repo.insert!(%Token{id: token_id, status: "available"})

      AssignToken.assign_token(user_id)

      response =
        conn
        |> get("/api/token/#{token_id}")
        |> json_response(200)

      assert %{
               "id" => ^token_id,
               "status" => "active",
               "user_id" => ^user_id,
               "users_history" => [%{"user_id" => ^user_id}]
             } = response
    end
  end
end
