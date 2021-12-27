defmodule Web.Controller do
  use Phoenix.Controller

  def index(conn, _params) do
    conn
    |> put_layout(false)
    |> Plug.Conn.send_file(200, "static/index.html")
  end

  def game(conn, _params) do
    Plug.Conn.send_file(conn, 200, "static/game.html")
  end
end
