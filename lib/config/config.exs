import Config

config :bomb,
  max_players: 9,
  grace: 7

import_config "#{config_env()}.exs"
