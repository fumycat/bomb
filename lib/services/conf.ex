defmodule Services.Conf do
  @config_table :ets_config_table

  def init_conf() do
    {:ok, config} =
      Path.join(File.cwd!(), "cfg/app.yaml")
      |> YamlElixir.read_from_file()

    configKw = Map.to_list(config)

    :ets.new(@config_table, [:set, :protected, :named_table])
    :ets.insert(@config_table, configKw)
    :ok
  end
end
