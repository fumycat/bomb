defmodule Ws do
  @moduledoc """
  https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/
  https://ninenines.eu/docs/en/cowboy/2.6/guide/ws_handlers/

  map update syntax
  %{oldmap | field: field_data}
  """
  @behaviour :cowboy_websocket
  @r Registry.Bomb

  def init(request, _state) do
    state = %{room_id: request.path}

    # IO.inspect request

    :logger.info("Joined room with id " <> request.path)

    {:cowboy_websocket, request, state, %{idle_timeout: 120_000}}
  end

  def websocket_init(state) do

    if Registry.count(Registry.Bomb) == 0 do
      agent_data = %{:admin => self()}
      GlobalState.create(state.room_id, agent_data)
    end

    GlobalState.add_player(state.room_id, self())

    Registry.register(Registry.Bomb, state.room_id, {})

    # no_admins =
    #   Enum.all?(Keyword.values(Registry.lookup(@r, state.room_id)), fn x -> x != true end)

    # IO.inspect(Registry.lookup(@r, state.room_id))
    # IO.inspect no_admins

    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    # [{_, {v}} | _] = Registry.lookup(Registry.Bomb, state.room_id)
    # a = Registry.values(Registry.Bomb, state.room_id, self())
    # IO.inspect(a)
    # b = Registry.lookup(Registry.Bomb, state.room_id)
    # IO.inspect(b)

    payload = Jason.decode!(json)

    textmsg = payload["data"]["message"]
    message = Jason.encode!(%{:msg => textmsg, :tmpdata => 0})

    broadcast(@r, state.room_id, message)

    IO.inspect GlobalState.get(state.room_id)

    {:reply, {:text, message}, state}
  end

  def websocket_info(info, state) do
    # recived via send
    # IO.inspect info
    {:reply, {:text, info}, state}
  end

  def broadcast(registry, key, message) do
    Registry.dispatch(registry, key, fn entries ->
      for {pid, _} <- entries do
        if pid != self() do
          Process.send(pid, message, [])
        end
      end
    end)
  end
end
