defmodule TokenManager.Commands.TokenHistoryTest do
  use TokenManager.DataCase, async: true

  alias TokenManager.Commands.TokenHistory
  alias TokenManager.Repo
  alias TokenManager.Schemas.TokenAudits

  describe "token_history/1" do
    test "fetches the history of users for a specific token" do
      token_id = Ecto.UUID.generate()
      user_id1 = Ecto.UUID.generate()
      user_id2 = Ecto.UUID.generate()

      audit1 =
        Repo.insert!(%TokenAudits{
          token_id: token_id,
          user_id: user_id1
        })

      audit2 =
        Repo.insert!(%TokenAudits{
          token_id: token_id,
          user_id: user_id2
        })

      history = TokenHistory.token_history(token_id)

      assert length(history) == 2
      assert Enum.at(history, 0).id == audit1.id
      assert Enum.at(history, 1).id == audit2.id
    end

    test "returns empty list when no history exists for the token" do
      token_id = Ecto.UUID.generate()

      history = TokenHistory.token_history(token_id)

      assert history == []
    end

    test "limits history to last 10 entries" do
      token_id = Ecto.UUID.generate()

      for _ <- 1..15 do
        Repo.insert!(%TokenAudits{
          token_id: token_id,
          user_id: Ecto.UUID.generate()
        })
      end

      history = TokenHistory.token_history(token_id)

      assert length(history) == 10
      assert Enum.all?(history, fn entry -> entry.token_id == token_id end)
    end
  end
end
