defmodule RoomManager do
  @moduledoc """
  Генсервер спавнится под BrainRegistry для каждой игровой комнаты.
  """
  require Logger
  use GenServer

  # Api

  # def register_player(room_id, pid),
  #   do: GenServer.call(process_name(room_id), {:register, pid})

  @spec tweak(String.t(), :lives | :players_max, integer()) :: any()
  def tweak(room_id, setting, value),
    do: GenServer.call(process_name(room_id), {:tweak, setting, value})

  @spec allow_join?(String.t(), integer()) :: boolean()
  def allow_join?(room_id, current_players),
    do: GenServer.call(process_name(room_id), {:allow_join, current_players})

  @spec child_spec({pid(), String.t()}) :: map()
  def child_spec(init_arg) do
    %{
      id: RoomManager,
      start: {RoomManager, :start_link, [init_arg]}
    }
  end

  @spec start_link({pid(), String.t()}) :: :ignore | {:error, term()} | {:ok, pid()}
  def start_link({_pid, room_id} = init_arg),
    do: GenServer.start_link(__MODULE__, init_arg, name: process_name(room_id))

  # Callbacks

  @impl true
  def init({pid, room_id}) do
    state = %{
      room_id: room_id,
      admin_pid: pid,
      # actual_players: [], TODO
      turn: nil,
      used_words: [],
      settings: %{
        lives: Application.fetch_env!(:bomb, :lives_def),
        players_max: Application.fetch_env!(:bomb, :players_max)
      }
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:allow_join, current_players}, _from, state) do
    Logger.debug("RoomManager allow_join call")
    allow = current_players < state.settings.players_max
    {:reply, allow, state}
  end

  @impl true
  def handle_call({:tweak, key, value} = log_msg, {pid, _}, state) do
    if state.admin_pid == pid do
      try do
        Logger.debug("RoomManager tweak #{log_msg}")
        new_state = put_in(state, [:settings, key], value)
        {:reply, :ok, new_state}
      rescue
        FunctionClauseError ->
          Logger.warning("RoomManager tweak #{log_msg} function clause")
          {:reply, :error, state}
      end
    else
      Logger.notice("RoomManager tweak permission_denied from pid: #{pid} msg: #{log_msg}")
      {:reply, :permission_denied, state}
    end
  end

  # def handle_call({:register, pid}, _from, state) do
  #   Logger.debug("RoomManager is_open call")
  #   {:reply, state.open, state}
  # end

  # Helper functions

  @spec process_name(String.t()) :: {:via, term(), term()}
  defp process_name(person),
    do: {:via, Registry, {BrainRegistry, person}}
end
