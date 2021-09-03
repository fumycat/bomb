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
    IO.inspect(request)
    :logger.info("Joined room with id " <> request.path)

    state = %{
      room_id: request.path,
      admin: false,
      started: false,
      order: nil,
      used_words: [],
      others: [],
      name: "Guest #{:rand.uniform(20)}",
      grace: Application.fetch_env!(:bomb, :grace),
      max_players: Application.fetch_env!(:bomb, :max_players)
    }

    {:cowboy_websocket, request, state, %{idle_timeout: 120_000}}

    # uri_params = URI.decode_query(request.qs)

    # IO.inspect(uri_params)

    # case Map.has_key?(uri_params, "u") do
    #   true ->
    #     state2 = %{state | p: uri_params["u"]}
    #     {:cowboy_websocket, request, state2, %{idle_timeout: 120_000}}

    #   false ->
    #     :logger.info("Request without identity")
    #     # a kak
    #     false
    # end
  end

  def websocket_init(state) do
    players = Registry.lookup(@r, state.room_id)
    state = %{state | admin: players == []}


    if length(players) < 9 do
      ^state = %{state | order: length(players)}
    end

    Registry.register(@r, state.room_id, {})

    {:ok, state}
  end

  def websocket_handle({:text, json}, state) do
    payload = Jason.decode!(json)

    case payload["action"] do
      "register" ->
        IO.puts("TODO")
    end

    textmsg = payload["data"]["message"]
    message = Jason.encode!(%{:msg => textmsg, :tmpdata => 0})

    broadcast(@r, state.room_id, {:normal_msg, message})

    # IO.inspect(Registry.lookup(@r, state.room_id))
    IO.inspect(state)

    # IO.inspect([">", self(), textmsg])

    {:reply, {:text, message}, state}
  end

  def websocket_info(info, state) do
    # received via send
    # IO.inspect info
    case info do
      {:normal_msg, message} ->
        {:reply, {:text, message}, state}

      {_, _} ->
        :logger.info("ws info nothing")
        {:ok, state}
    end
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
