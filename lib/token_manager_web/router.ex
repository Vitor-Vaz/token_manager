defmodule TokenManagerWeb.Router do
  use TokenManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Define your API routes here
  scope "/api", TokenManagerWeb do
    pipe_through :api

    post "/assign_token/:user_id", TokenController, :assign_token
    get "/tokens", TokenController, :list
  end
end
