defmodule TokenManager.Schemas.TokenAudits do
  @moduledoc """
  Schema for managing token audits in the TokenManager application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @required_fields [:token_id, :user_id]

  schema "token_audits" do
    field :token_id, Ecto.UUID
    field :user_id, Ecto.UUID

    timestamps()
  end

  def changeset(token_audit, attrs) do
    token_audit
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
