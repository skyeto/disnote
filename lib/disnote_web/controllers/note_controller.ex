defmodule DisnoteWeb.NoteController do
  use DisnoteWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
