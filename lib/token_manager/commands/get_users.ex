defmodule TokenManager.Commands.GetUsers do
  @moduledoc """
    Command module to get users from the system.
  """

  import Ecto.Query, warn: false

  alias TokenManager.Repo
  alias TokenManager.Schemas.User

  def get(limit \\ 10) do
    from(u in User,
      select: u,
      limit: ^limit
    )
    |> Repo.all()
  end
end
