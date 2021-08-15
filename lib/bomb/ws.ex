defmodule Ws do
  @moduledoc """
  https://ninenines.eu/docs/en/cowboy/2.6/manual/cowboy_websocket/
  https://ninenines.eu/docs/en/cowboy/2.6/guide/ws_handlers/

  map update syntax
  %{oldmap | field: field_data}
  """
  @behaviour :cowboy_websocket

  def init(request, _state) do
    state = %{registry_key: request.path}

    :logger.info("Joined room with id " <> request.path)

    {:cowboy_websocket, request, state, %{idle_timeout: 120_000}}
  end

  def websocket_init(state) do
    Registry.register(Registry.Bomb, state.registry_key, {:tmpe})
    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    [{_, {v}} | _] = Registry.lookup(Registry.Bomb, state.registry_key)

    payload = Jason.decode!(json)

    textmsg = payload["data"]["message"]
    message = Jason.encode!(%{:msg => textmsg, :tmpdata => v})

    Registry.dispatch(Registry.Bomb, state.registry_key, fn entries ->
      for {pid, _} <- entries do
        if pid != self() do
          Process.send(pid, message, [])
        end
      end
    end)

    {:reply, {:text, message}, state}
  end

  def websocket_info(info, state) do
    # recived via send
    # IO.inspect info
    {:reply, {:text, info}, state}
  end
end
