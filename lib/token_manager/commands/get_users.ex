defmodule TokenManager.Commands.GetUsers do
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
