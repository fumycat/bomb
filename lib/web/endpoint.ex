defmodule Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :explosive

  plug(Plug.Static,
    at: "/",
    from: "static",
    only: ~w(index.html game.html index.js game.js bomb.svg)
  )

  plug(Web.Router)
end
