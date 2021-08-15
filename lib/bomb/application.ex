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
        plug: Base,
        options: [
          dispatch: [
            {:_,
             [
               {"/ws/[...]", Ws, []},
               {:_, Plug.Cowboy.Handler, {Base, []}}
             ]}
          ],
          port: 4000
        ]
      ),
      Registry.child_spec(
        keys: :duplicate,
        name: Registry.Bomb
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Bomb.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
