defmodule PlayerWS do
  @moduledoc """
  https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/
  https://ninenines.eu/docs/en/cowboy/2.6/guide/ws_handlers/

  To send many frames at once, return a reply tuple with the list of frames to send:
  {reply, [
        {text, "Hello"},
        {text, <<"world!">>},
        {binary, <<0:8000>>}
    ], State}.

  map update syntax
  %{oldmap | field: field_data}

  Looking up, dispatching and registering are efficient and immediate at the
  cost of delayed unsubscription. For example, if a process crashes, its keys
  are automatically removed from the registry but the change may not propagate immediately.

  https://hexdocs.pm/elixir/Registry.html#unregister/2

  TODO add @type for ws state and update @spec's
  """
  @behaviour :cowboy_websocket
  @r PlayersRegistry

  require Logger

  @enforce_keys [:room_id, :name]
  defstruct [:room_id, :name, :is_admin, :is_spectator]

  @impl true
  def init(request, _state) do
    # IO.inspect(request)
    Logger.info("Joined room with id " <> request.path)

    state = %PlayerWS{
      room_id: request.path,
      name: "Guest #{:rand.uniform(20)}"
    }

    {:cowboy_websocket, request, state, %{idle_timeout: 120_000}}
  end

  @impl true
  def websocket_init(state) do
    players = Registry.lookup(@r, state.room_id)

    if players == [] do
      case DynamicSupervisor.start_child(
             BrainSupervisor,
             RoomManager.child_spec({self(), state.room_id})
           ) do
        {:error, why} ->
          Logger.error("Failed to start game room: #{state.room_id} reason: #{inspect(why)}")

        # TODO send error to user?

        :ignore ->
          Logger.critical("Not implemeted :ignore room: #{state.room_id}")

        _ ->
          Logger.info("Successfuly started game GenServer room: #{state.room_id}")
      end
    end

    Registry.register(@r, state.room_id, {})

    registered = RoomManager.register_player(state.room_id)

    new_state = %{state | is_admin: players == [], is_spectator: not registered}

    {:ok, new_state}
  end

  @impl true
  def websocket_handle({:text, json}, state) do
    case Jason.decode(json) do
      {:ok, payload} ->
        Logger.debug("in ws msg; room: #{state.room_id} msg: #{inspect(payload)}")
        # TODO logic here
        {:ok, state}

      {:error, _} ->
        # clown protection
        :timer.sleep(1000)
        Logger.notice("bad ws msg; room: #{state.room_id} msg: #{inspect(json)}")
        {:reply, {:text, "{\"error\":\"Bad message\"}"}, state}
    end

    # case payload["action"] do
    #   "register" ->
    #     IO.puts("TODO")
    # end
  end

  # Received via send
  @impl true
  def websocket_info({:normal_msg, message}, state) do
    Logger.debug("ws info room: #{state.room_id} msg: #{message}")
    {:reply, {:text, message}, state}
  end

  def websocket_info(any, state) do
    Logger.warning("ws info unknown message room: #{state.room_id} msg: #{any}")
    {:ok, state}
  end

  @impl true
  def terminate(reason, _req, state) do
    case reason do
      {:crash, c, r} ->
        Logger.error(
          "WS connection terminated in room: #{state.room_id} (crash) #{inspect(c)} #{inspect(r)}"
        )

      {:error, r} ->
        Logger.error("WS connection terminated in room: #{state.room_id} (error) #{inspect(r)}")

      _ ->
        Logger.debug("WS connection terminated in room: #{state.room_id}")
    end
  end

  # Helper functions

  @spec broadcast(String.t(), {atom(), String.t()}) :: :ok
  def broadcast(room_id, message) do
    Registry.dispatch(@r, room_id, fn entries ->
      for {pid, _} <- entries do
        if pid != self() do
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
