defmodule Router do
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

  get "/" do
    Plug.Conn.send_file(conn, 200, "static/index.html")
  end

  match _ do
    # IO.inspect(conn)
    p = conn.request_path |> String.slice(1..-1)

    case File.exists?(p) do
      true ->
        Plug.Conn.send_file(conn, 200, p)

      false ->
        case String.match?(p, ~r/^[A-z]{5}$/) do
          true ->
            Plug.Conn.send_file(conn, 200, "static/game.html")

          false ->
            send_resp(conn, 404, "404")
        end
    end
  end
end
