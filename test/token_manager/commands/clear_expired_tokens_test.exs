defmodule TokenManager.Commands.ClearExpiredTokensTest do
  use TokenManager.DataCase, async: true

  alias TokenManager.Repo
  alias TokenManager.Schemas.Token
  alias TokenManager.Commands.ClearExpiredTokens

  describe "execute" do
    test "releases tokens that have expired" do
      now = DateTime.utc_now()
      past = DateTime.add(now, -60, :second) |> DateTime.truncate(:second)

      expired_token =
        Repo.insert!(%Token{
          status: "active",
          user_id: Ecto.UUID.generate(),
          expires_at: past
        })

      future = DateTime.add(now, 60, :second) |> DateTime.truncate(:second)

      active_token =
        Repo.insert!(%Token{
          status: "active",
          user_id: Ecto.UUID.generate(),
          expires_at: future
        })

      available_token = Repo.insert!(%Token{status: "available"})

      assert :ok = ClearExpiredTokens.execute()

      expired_token = Repo.reload!(expired_token)
      assert expired_token.status == "available"
      assert expired_token.user_id == nil
      assert expired_token.expires_at == nil

      active_token = Repo.reload!(active_token)
      assert active_token.status == "active"
      assert active_token.user_id != nil
      assert active_token.expires_at != nil

      available_token = Repo.reload!(available_token)
      assert available_token.status == "available"
    end

    test "handles multiple expired tokens" do
      past = DateTime.utc_now() |> DateTime.add(-60) |> DateTime.truncate(:second)

      for _ <- 1..5 do
        Repo.insert!(%Token{
          status: "active",
          user_id: Ecto.UUID.generate(),
          expires_at: past
        })
      end

      assert :ok = ClearExpiredTokens.execute()

      available_count = Repo.aggregate(Token, :count, :id, where: [status: "available"])
      assert available_count == 5

      assert from(t in Token, where: t.status == "active")
             |> Repo.all()
             |> Enum.empty?()
    end

    test "does nothing when no tokens are expired" do
      now = DateTime.utc_now()
      future = DateTime.add(now, 60) |> DateTime.truncate(:second)

      Repo.insert!(%Token{
        status: "active",
        user_id: Ecto.UUID.generate(),
        expires_at: future
      })

      assert :ok = ClearExpiredTokens.execute()

      active_count = Repo.aggregate(Token, :count, :id, where: [status: "active"])
      assert active_count == 1
    end

    test "returns :ok when no tokens exist" do
      assert :ok = ClearExpiredTokens.execute()
    end
  end
end
