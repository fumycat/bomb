defmodule Base do
  @moduledoc """
  https://hexdocs.pm/plug/Plug.Router.html
  """
  use Plug.Router

  plug(Plug.Static,
    at: "/",
    from: "static"
  )

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason
  )

  plug(:dispatch)

  # EEx.function_from_file(:defp, :application_html, "lib/application.html.eex", [])

  get "/" do
    # send_resp(conn, 200, "test")
    Plug.Conn.send_file(conn, 200, "static/index.html")
  end

  match _ do
    Plug.Conn.send_file(conn, 200, "static/index.html")

    # send_resp(conn, 404, "404")
  end
end
