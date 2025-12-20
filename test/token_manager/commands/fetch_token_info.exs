defmodule TokenManager.Commands.FetchTokenInfoTest do
  use TokenManager.DataCase, async: true

  alias TokenManager.Commands.AssignToken
  alias TokenManager.Commands.FetchTokenInfo
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.TokenAudits
  alias TokenManager.Schemas.User

  describe "fetch_token_info/1" do
    test "returns token info with user and audits when token is active" do
      user_id = Ecto.UUID.generate()
      token_id = Ecto.UUID.generate()
      Repo.insert!(%User{id: user_id})
      Repo.insert!(%Token{id: token_id})

      AssignToken.assign_token(user_id)

      token_info = FetchTokenInfo.fetch_token_info(token_id)

      assert %{
               token: %Token{id: ^token_id},
               user: %User{id: ^user_id},
               audits: audits
             } = token_info

      assert length(audits) == 1

      [audit] = audits

      assert %TokenAudits{
               user_id: ^user_id,
               token_id: ^token_id
             } = audit
    end

    test "returns token info with nil user when token is available" do
      token_id = Ecto.UUID.generate()

      Repo.insert!(%Token{id: token_id, status: "available"})

      token_info = FetchTokenInfo.fetch_token_info(token_id)

      assert %{
               token: %Token{id: ^token_id},
               user: nil,
               audits: []
             } = token_info
    end

    test "returns error when token not found" do
      non_existent_token_id = Ecto.UUID.generate()

      assert {:error, :token_not_found} =
               FetchTokenInfo.fetch_token_info(non_existent_token_id)
    end

    test "returns token info with last 10 audits" do
      user_id = Ecto.UUID.generate()
      token_id = Ecto.UUID.generate()
      Repo.insert!(%User{id: user_id})
      Repo.insert!(%Token{id: token_id})

      for _ <- 1..15 do
        Repo.insert!(%TokenAudits{token_id: token_id, user_id: user_id})
      end

      token_info = FetchTokenInfo.fetch_token_info(token_id)

      assert %{
               token: %Token{id: ^token_id},
               user: nil,
               audits: audits
             } = token_info

      assert length(audits) == 10

      assert Enum.all?(audits, fn audit -> audit.token_id == token_id end)
      assert Enum.all?(audits, fn audit -> audit.user_id == user_id end)
    end
  end
end
