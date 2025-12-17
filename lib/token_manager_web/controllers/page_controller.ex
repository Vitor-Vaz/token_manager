defmodule TokenManagerWeb.PageController do
  use TokenManagerWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
