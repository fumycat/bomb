defmodule Bomb.Player do

  @type player :: %{
    :fp => String.t(),
    :pid => pid(),
    :name => String.t(),
    :lives => integer()
  }

  @spec init(player()) :: {:ok, any()}
  def init(init_player) do
    {:ok, init_player}
  end

end
