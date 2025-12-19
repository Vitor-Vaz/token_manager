defmodule TokenManager.Schemas.User do
  @moduledoc """
  Schema for managing users in the TokenManager application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "users" do
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
  end
end
