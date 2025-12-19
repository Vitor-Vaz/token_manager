defmodule TokenManager.Schemas.Token do
  @moduledoc """
  Schema for managing tokens in the TokenManager application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  @optional_fields [:expires_at, :user_id]

  @status_values ["available", "active"]

  schema "tokens" do
    field :status, :string, default: "available"
    field :expires_at, :utc_datetime
    field :user_id, Ecto.UUID

    timestamps()
  end

  def changeset(token, attrs) do
    token
    |> cast(attrs, @optional_fields ++ [:status])
    |> validate_required([:status])
    |> validate_inclusion(:status, @status_values)
  end
end
