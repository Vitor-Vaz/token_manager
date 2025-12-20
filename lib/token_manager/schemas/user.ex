defmodule TokenManager.Schemas.User do
  @moduledoc """
  Schema for managing users in the TokenManager application.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}

  schema "users" do
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [])
  end
end
