defmodule Bomb.Game do

  use GenServer

  @impl true
  def init({pid, fp, room_id}) do
    lives = Services.Conf.get_conf("lives")
    state = %{
      room_id: room_id,
      admin_fp: fp,
      admin_pid: pid,
      players: [],
      turn: :nil,
      used_words: [],
      settings: %{
        lives: Map.get(lives, "default")
      }
    }
    {:ok, state}
  end

end
