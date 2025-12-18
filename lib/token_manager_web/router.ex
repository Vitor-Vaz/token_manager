defmodule TokenManagerWeb.Router do
  use TokenManagerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Define your API routes here
  # scope "/api", TokenManagerWeb do
  #   pipe_through :api
  # end
end
