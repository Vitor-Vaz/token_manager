defmodule TokenManager.Commands.ListTokensTest do
  use TokenManager.DataCase, async: true

  alias TokenManager.Commands.ListTokens
  alias TokenManager.Schemas.Token

  describe "list/1" do
    test "lists all tokens without filters" do
      for _ <- 1..5 do
        Repo.insert!(%Token{status: "available"})
      end

      tokens = ListTokens.list(%ListTokens{})
      assert length(tokens) == 5
    end

    test "lists tokens filtered by status" do
      Repo.insert!(%Token{status: "available"})
      Repo.insert!(%Token{status: "active"})

      available_tokens = ListTokens.list(%ListTokens{status: "available"})
      active_tokens = ListTokens.list(%ListTokens{status: "active"})

      assert length(available_tokens) == 1
      assert Enum.all?(available_tokens, fn t -> t.status == "available" end)

      assert length(active_tokens) == 1
      assert Enum.all?(active_tokens, fn t -> t.status == "active" end)
    end

    test "lists tokens filtered by user_id" do
      user_id = Ecto.UUID.generate()
      Repo.insert!(%Token{status: "active", user_id: user_id})
      Repo.insert!(%Token{status: "available", user_id: nil})

      tokens = ListTokens.list(%ListTokens{user_id: user_id})

      assert length(tokens) == 1
      assert Enum.all?(tokens, fn t -> t.user_id == user_id end)
    end

    test "lists tokens filtered by expires_before" do
      now = DateTime.utc_now()

      past_time = now |> DateTime.add(30, :second) |> DateTime.truncate(:second)
      expires_before_time = now |> DateTime.add(60, :second) |> DateTime.truncate(:second)
      future_time = now |> DateTime.add(120, :second) |> DateTime.truncate(:second)

      Repo.insert!(%Token{status: "active", expires_at: nil})
      Repo.insert!(%Token{status: "active", expires_at: past_time})
      Repo.insert!(%Token{status: "active", expires_at: future_time})

      tokens = ListTokens.list(%ListTokens{expires_before: expires_before_time})

      assert length(tokens) == 1

      assert Enum.all?(tokens, fn t ->
               DateTime.compare(t.expires_at, expires_before_time) == :lt
             end)
    end

    test "lists tokens with combined filters" do
      user_id = Ecto.UUID.generate()

      Repo.insert!(%Token{status: "active", user_id: user_id})

      Repo.insert!(%Token{status: "available", user_id: nil})

      [token] =
        ListTokens.list(%ListTokens{status: "active", user_id: user_id})

      assert token.status == "active"
      assert token.user_id == user_id
    end

    test "returns empty list when no tokens match filters" do
      tokens = ListTokens.list(%ListTokens{})
      assert tokens == []
    end
  end
end
