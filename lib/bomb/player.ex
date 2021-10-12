defmodule Bomb.Player do
  use GenServer

  @type player :: %{
    :fp => String.t(),
    :pid => pid(),
    :name => String.t(),
    :lives => integer()
  }

  @impl true
  @spec init(player()) :: {:ok, any()}
  def init(init_player) do
    {:ok, init_player}
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  # def handle_call({:char, value}, from, state) do
    #
  # end
end
