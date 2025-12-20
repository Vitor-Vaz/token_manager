defmodule TokenManager.Commands.AssignTokenTest do
  use TokenManager.DataCase, async: true

  alias TokenManager.Commands.AssignToken
  alias TokenManager.Schemas.Token
  alias TokenManager.Schemas.User
  alias TokenManager.Schemas.TokenAudits

  describe "assign_token/1" do
    test "successfully assigns an available token to a user" do
      user_id = Ecto.UUID.generate()

      Repo.insert(%User{id: user_id})
      Repo.insert(%Token{id: Ecto.UUID.generate(), status: "available"})

      result = AssignToken.assign_token(user_id)

      updated_token = Repo.get(Token, result.token_id)
      assert updated_token.status == "active"
      assert updated_token.user_id == user_id
      assert updated_token.expires_at != nil
    end

    test "should force assign a token when doen't have available tokens" do
      user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: user_id})
      Repo.insert(%Token{id: Ecto.UUID.generate(), status: "available"})

      first_result = AssignToken.assign_token(user_id)

      second_user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: second_user_id})

      Repo.insert(%Token{id: Ecto.UUID.generate(), status: "available"})

      second_result = AssignToken.assign_token(second_user_id)

      assert first_result.token_id != second_result.token_id
      assert user_id == first_result.user_id
      assert second_user_id == second_result.user_id

      third_user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: third_user_id})

      third_result = AssignToken.assign_token(third_user_id)

      assert third_result.token_id == first_result.token_id
      assert third_user_id == third_result.user_id
    end

    test "should validate if 10 tokens are reused by 15 users" do
      for _ <- 1..10 do
        token_id = Ecto.UUID.generate()
        Repo.insert!(%Token{id: token_id, status: "available"})
      end

      user_ids =
        for _ <- 1..15 do
          user_id = Ecto.UUID.generate()
          Repo.insert!(%User{id: user_id})
          user_id
        end

      first_10_results =
        user_ids
        |> Enum.take(10)
        |> Enum.map(fn user_id ->
          result = AssignToken.assign_token(user_id)
          Process.sleep(10)
          result
        end)

      assigned_token_ids = Enum.map(first_10_results, & &1.token_id)
      assert length(Enum.uniq(assigned_token_ids)) == 10

      first_5_assigned_token_ids = Enum.take(assigned_token_ids, 5)

      last_5_results =
        user_ids
        |> Enum.drop(10)
        |> Enum.map(fn user_id ->
          AssignToken.assign_token(user_id)
        end)

      reused_token_ids = Enum.map(last_5_results, & &1.token_id)

      # validate if last 5 tokens are reused from first 5 assigned tokens
      assert Enum.sort(reused_token_ids) == Enum.sort(first_5_assigned_token_ids)
    end

    test "should register audit when assigning a token" do
      for _ <- 1..3 do
        token_id = Ecto.UUID.generate()
        Repo.insert!(%Token{id: token_id, status: "available"})
      end

      users =
        for _ <- 1..5 do
          user_id = Ecto.UUID.generate()
          Repo.insert!(%User{id: user_id})
          user_id
        end

      results =
        users
        |> Enum.map(fn user_id ->
          result = AssignToken.assign_token(user_id)
          Process.sleep(10)
          result
        end)

      audits = Repo.all(from(ta in TokenAudits))
      assert length(audits) == 5

      result_user_ids = Enum.map(results, & &1.user_id)
      result_token_ids = Enum.map(results, & &1.token_id)

      audit_users = Enum.map(audits, & &1.user_id)
      audit_tokens = Enum.map(audits, & &1.token_id)

      assert Enum.sort(result_user_ids) == Enum.sort(audit_users)
      assert Enum.sort(result_token_ids) == Enum.sort(audit_tokens)
    end

    test "returns error when user does not exist" do
      non_existent_user_id = Ecto.UUID.generate()

      result = AssignToken.assign_token(non_existent_user_id)

      assert result == {:error, :user_not_found}
    end

    test "returns existing active token if user already has one" do
      user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: user_id})

      existing_token =
        Repo.insert!(%Token{id: Ecto.UUID.generate(), status: "active", user_id: user_id})

      result = AssignToken.assign_token(user_id)

      assert result == %{token_id: existing_token.id, user_id: user_id}
    end

    test "returns error when token assignment fails" do
      user_id = Ecto.UUID.generate()
      Repo.insert(%User{id: user_id})

      result = AssignToken.assign_token(user_id)

      assert result == {:error, :failed_to_fetch_last_active_token}
    end
  end
end
