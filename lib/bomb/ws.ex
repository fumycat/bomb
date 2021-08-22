defmodule Ws do
  @moduledoc """
  https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/
  https://ninenines.eu/docs/en/cowboy/2.6/guide/ws_handlers/

  map update syntax
  %{oldmap | field: field_data}

  Looking up, dispatching and registering are efficient and immediate at the
  cost of delayed unsubscription. For example, if a process crashes, its keys
  are automatically removed from the registry but the change may not propagate immediately.
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
    if Registry.count(@r) == 0 do
      # first client
      agent_data = %{:admin => self()}
      GlobalState.create(state.room_id, agent_data)
    end

    Registry.register(@r, state.room_id, {})

    # test room cap
    if Registry.count(@r) > 3 do
      Process.send(self(), Jason.encode!(%{:msg => "sorry)", :tmpdata => 0}), [])
    end

    GlobalState.add_player(state.room_id, self())
    # TODO FIX PIDs stays in agent after connection drops
    # should use some ids instead of pids

    # no_admins =
    #   Enum.all?(Keyword.values(Registry.lookup(@r, state.room_id)), fn x -> x != true end)

    # IO.inspect Registry.lookup(@r, state.room_id)

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

    # test kill
    if textmsg == "killme" do
      GlobalState.kill_player(state.room_id, self())
    end

    IO.inspect GlobalState.get(state.room_id)
    IO.inspect(Registry.lookup(@r, state.room_id))
    IO.inspect [">", self(), textmsg]

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
