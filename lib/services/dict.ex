defmodule Services.Dict do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: {:global, :dict_server})
  end

  @impl true
  def init(_init_arg) do
    set = :gb_sets.new()

    filled_set =
      File.read!("cfg/words.txt")
      |> String.split()
      |> List.foldl(set, fn e, acc -> :gb_sets.add(e, acc) end)

    {:ok, filled_set}
  end

  @impl true
  def handle_call({:ask, key}, _from, state) do
    ans = :gb_sets.is_element(key, state)
    {:reply, ans, state}
  end

  def check(word) do
    GenServer.call({:global, :dict_server}, {:ask, word})
  end
end
