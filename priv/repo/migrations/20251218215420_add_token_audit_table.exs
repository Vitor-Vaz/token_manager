defmodule TokenManager.Repo.Migrations.AddTokenAuditTable do
  use Ecto.Migration

  def change do
    create table(:token_audits, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :token_id, :uuid, null: false
      add :user_id, :uuid, null: false
      timestamps()
    end
  end
end
