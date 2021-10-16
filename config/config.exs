use Mix.Config

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:pid]

config :bomb,
  players_min: 3,
  players_max: 10,
  lives_min: 1,
  lives_max: 5,
  lives_def: 2,
  grace_min: 3,
  grace_max: 20,
  grace_def: 7
