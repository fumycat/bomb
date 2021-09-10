defmodule Eye do
  @moduledoc """
    Monitoring a single game room.
  """
  require Logger

  use GenServer

  def start_link(pid, room_id) do
    GenServer.start_link(__MODULE__, pid, name: {:via, Registry, {EyesRegistry, "eye#{room_id}"}})
  end

  def join(room_id) do
    server = {:via, Registry, {EyesRegistry, "eye#{room_id}"}}
    GenServer.call(server, :join)
  end

  @impl true
  def init(admin_pid) do
    state = %{admin: admin_pid, others: []}
    {:ok, state}
  end

  @impl true
  def handle_call(:join, {pid_from, _tag}, state) do
    new_state = Map.update!(state, :others, fn l -> [pid_from | l] end)
    Process.monitor(pid_from)
    {:reply, :ok, new_state}
  end

  # This callback is optional. If one is not implemented, the received message will be logged.
  # does work
  # [error] Eye #PID<0.388.0> received unexpected message in handle_info/2: {:DOWN, #Reference<0.4106046526.3954442241.215774>, :process, #PID<0.391.0>, :normal}
  # does work
  # @impl true
  # def handle_info(msg, state) do
  #   # TODO https://hexdocs.pm/elixir/1.12/Process.html#monitor/1
  #   {:noreply, state}
  # end
end
