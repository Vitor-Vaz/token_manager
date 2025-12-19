defmodule TokenManager.Commands.AssignTokenTest do
  use ExUnit.Case, async: true
  alias TokenManager.Commands.AssignToken
  alias TokenManager.Repo
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.User

  describe "assassign_token/1" do
    setup do
      :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)

      user_id = Ecto.UUID.generate()

      Repo.insert(%User{id: user_id})
      Repo.insert(%Token{id: Ecto.UUID.generate(), status: "available"})

      {:ok, user_id: user_id}
    end

    test "successfully assigns an available token to a user", %{user_id: user_id} do
      result = AssignToken.assign_token(user_id)

      updated_token = Repo.get(Token, result.token_id)
      assert updated_token.status == "active"
      assert updated_token.user_id == user_id
      assert updated_token.expires_at != nil
    end

    test "should force assign a token when no available tokens", %{user_id: user_id} do
      first_result = AssignToken.assign_token(user_id)

      another_user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: another_user_id})

      second_result = AssignToken.assign_token(another_user_id)
      assert first_result.token_id == second_result.token_id
      assert first_result.user_id != second_result.user_id
    end

    # test "returns error when no available tokens" do
    #   user = Repo.insert!(%User{id: Ecto.UUID.generate()})

    #   result = AssignToken.assign_token(user.id)

    #   assert result == {:error, :no_available_tokens}
    # end

    # test "returns error when user not found" do
    #   non_existent_user_id = Ecto.UUID.generate()

    #   result = AssignToken.assign_token(non_existent_user_id)

    #   assert result == {:error, :user_not_found}
    # end
  end
end
