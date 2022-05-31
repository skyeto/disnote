defmodule DisnoteWeb.PageController do
  use DisnoteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
