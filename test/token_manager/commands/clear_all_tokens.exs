defmodule TokenManager.Commands.ClearAllTokensTest do
  use TokenManager.DataCase, async: true

  import Ecto.Query, warn: false

  alias TokenManager.Commands.ClearAllTokens
  alias TokenManager.Repo
  alias TokenManager.Schemas.Token

  describe "clear_all/0" do
    test "clears all tokens by setting their status to available and removing user associations" do
      for _ <- 1..5 do
        Repo.insert!(%Token{
          status: "active",
          user_id: Ecto.UUID.generate(),
          expires_at:
            DateTime.utc_now() |> DateTime.add(120, :second) |> DateTime.truncate(:second)
        })
      end

      assert :ok == ClearAllTokens.clear_all()
      tokens = Repo.all(from(t in Token))

      assert Enum.all?(tokens, fn t ->
               t.status == "available" and is_nil(t.user_id) and is_nil(t.expires_at)
             end)
    end

    test "returns :ok when there are no tokens to clear" do
      assert :ok == ClearAllTokens.clear_all()
      tokens = Repo.all(from(t in Token))
      assert tokens == []
    end
  end
end
