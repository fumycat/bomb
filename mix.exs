defmodule Bomb.MixProject do
  use Mix.Project

  def project do
    [
      app: :bomb,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      default_task: "run",
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Bomb.Application, []},
      env: [
        grace: 7,
        max_players: 9
      ]
    ]
  end

  defp aliases do
    [
      dev_elm: [
        "cmd mix elm_dev elm/Index.elm static/index.js",
        "cmd mix elm_dev elm/Settings.elm static/settings.js",
        "cmd mix elm_dev elm/Game.elm static/game.js"
      ],
      elm: [
        "cmd mix elm_prod elm/Index.elm static/index.js",
        "cmd mix elm_prod elm/Settings.elm static/settings.js",
        "cmd mix elm_prod elm/Game.elm static/game.js"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
