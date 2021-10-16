defmodule Bomb.Game do
  require Logger
  use GenServer

  # API

  @spec start_link({pid(), String.t(), String.t()}) :: :ignore | {:error, term()} | {:ok, pid()}
  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end



  # Callbacks

  @impl true
  def init({pid, fp, room_id}) do
    state = %{
      room_id: room_id,
      admin_fp: fp,
      admin_pid: pid,
      players: [],
      turn: nil,
      used_words: [],
      settings: %{
        lives: Application.fetch_env!(:bomb, :lives_def)
      }
    }

    Logger.info("Successfuly initialized ")
    {:ok, state}
  end

  @impl true
  def handle_call(request, from, state) do

  end
end
