defmodule RoomManager do
  @moduledoc """
  Генсервер спавнится под ManagerSupervisor для каждой игровой комнаты.
  """
  require Logger
  use GenServer

  @enforce_keys [:room_id, :admin_pid, :settings]
  defstruct [:room_id, :admin_pid, :settings, :turn, used_words: [], actual_players: []]

  @type t :: %RoomManager{
          room_id: String.t(),
          admin_pid: pid(),
          settings: map(),
          # TODO?
          turn: any(),
          used_words: [String.t()],
          actual_players: [pid()]
        }

  # Api

  @spec tweak(String.t(), :lives | :players_max, integer()) :: any()
  def tweak(room_id, setting, value),
    do: GenServer.call(process_name(room_id), {:tweak, setting, value})

  @spec register_player(String.t()) :: boolean()
  def register_player(room_id),
    do: GenServer.call(process_name(room_id), {:register_player})

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
    state = %RoomManager{
      room_id: room_id,
      admin_pid: pid,
      settings: %{
        lives: Application.fetch_env!(:bomb, :lives_def),
        players_max: Application.fetch_env!(:bomb, :players_max)
      }
    }

    {:ok, state}
  end

  @impl true
  def handle_call({:register_player}, {pid, _} = _from, state) do
    Logger.debug("RoomManager register_player call")
    Process.monitor(pid)
    # care about spectators for now

    if length(state.actual_players) <= state.settings.players_max do
      new_state = %{state | actual_players: [pid | state.actual_players]}
      {:reply, true, new_state}
    else
      {:reply, false, state}
    end
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

  @impl true
  def handle_info({:DOWN, _ref, :process, object, _reason}, state) do
    # TODO notify about player leaving
    new_state = %{state | actual_players: state.actual_players -- [object]}

    Logger.debug(
      "Process #{inspect(object)} down in room #{state.room_id} players left: #{length(new_state.actual_players)}"
    )

    {:noreply, new_state}
  end

  @impl true
  def handle_info(msg, state) do
    Logger.warning("Unhandled info in room #{state.room_id}: #{inspect(msg)}")
    {:noreply, state}
  end

  # Helper functions

  @spec process_name(String.t()) :: {:via, term(), term()}
  defp process_name(person),
    do: {:via, Registry, {ManagersRegistry, person}}

  @spec broadcast(String.t(), {atom(), String.t()}, [pid()]) :: :ok
  def broadcast(room_id, message, blacklist) do
    Registry.dispatch(PlayersRegistry, room_id, fn entries ->
      for {pid, _} <- entries do
        if Enum.member?(blacklist, pid) do
          case Process.send(pid, message, []) do
            :ok ->
              :ok

            err ->
              Logger.warning(
                "broadcast send err room: #{room_id} err: #{err} dest pid: #{pid} msg: #{message}"
              )
          end
        end
      end
    end)
  end
end
