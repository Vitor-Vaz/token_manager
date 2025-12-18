defmodule TokenManager.Repo.Migrations.AddTokensTable do
  use Ecto.Migration

  def change do
    create table(:tokens, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :status, :string, default: "available", null: false
      add :expires_at, :utc_datetime
      add :user_id, :uuid

      timestamps()
    end
  end
end
