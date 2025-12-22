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
    get "/token/:token_id", TokenController, :fetch_token
    get "/token_history/:token_id", TokenController, :token_history
    put "/clear_all_tokens", TokenController, :clear_all_tokens

    get "/users/:quantity", UserController, :get_users
  end
end
