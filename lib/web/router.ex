defmodule Web.Router do
  use Phoenix.Router

  get("/", Web.Controller, :index)
  get("/:path", Web.Controller, :game)
end
