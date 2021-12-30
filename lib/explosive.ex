defmodule Explosive do
  @moduledoc false

  require Logger
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: Router,
        options: [
          dispatch: [
            {:_,
             [
               {"/ws/[...]", PlayerWS, []},
               {:_, Plug.Cowboy.Handler, {Router, []}}
             ]}
          ],
          port: 4000
        ]
      ),
      Registry.child_spec(
        name: PlayersRegistry,
        keys: :duplicate
      ),
      Registry.child_spec(
        name: ManagersRegistry,
        keys: :unique
      ),
      DynamicSupervisor.child_spec(
        restart: :transient,
        name: ManagerSupervisor,
        strategy: :one_for_one,
        max_children: Application.fetch_env!(:explosive, :games_max)
      ),
      Dictionary.child_spec()
    ]

    opts = [strategy: :one_for_one, name: Explosive.Supervisor]
    Logger.info("Running bomb app...")
    Supervisor.start_link(children, opts)
  end
end
