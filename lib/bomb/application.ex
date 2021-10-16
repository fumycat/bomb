defmodule Bomb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Bomb.Worker.start_link(arg)
      # {Bomb.Worker, arg}
      # {Plug.Cowboy, scheme: :http, plug: Base, options: [port: 4001]}
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Bomb.MainRouter,
        options: [
          dispatch: [
            {:_,
             [
               {"/ws/[...]", Bomb.Ws, []},
               {:_, Plug.Cowboy.Handler, {Bomb.MainRouter, []}}
             ]}
          ],
          port: 4000
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Bomb
      ),
      %{
        id: Services.Dict,
        start: {Services.Dict, :start_link, []}
      },
    ]

    opts = [strategy: :one_for_one, name: Bomb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
