# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TokenManager.Repo.insert!(%TokenManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias TokenManager.Repo
alias TokenManager.Schemas.Token
alias TokenManager.Schemas.User

Repo.delete_all(Token)
Repo.delete_all(User)

tokens =
  Enum.map(1..100, fn _ ->
    %{
      id: Ecto.UUID.generate(),
      expires_at: nil,
      user_id: nil,
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }
  end)

{count, _} = Repo.insert_all(Token, tokens)

IO.puts("✓ #{count} tokens criados com sucesso!")

users =
  Enum.map(1..10, fn _ ->
    %{
      id: Ecto.UUID.generate(),
      inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
      updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    }
  end)

{count, _} = Repo.insert_all(User, users)

IO.puts("✓ #{count} usuários criados com sucesso!")
