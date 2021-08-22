defmodule GlobalState do
  use Agent

  @name {:global, __MODULE__}

  def start_link do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def start_link([]) do
    Agent.start_link(fn -> %{} end, name: @name)
  end

  def create(room_id, data) do
    Agent.update(@name, fn state ->
      Map.put(state, room_id, data)
    end)
  end

  def add_player(room_id, pid) do
    Agent.update(@name, fn state ->
      Map.update!(state, room_id, fn room_data ->
        Map.update(room_data, :players, [pid], fn old_list ->
          old_list ++ [pid]
        end)
      end)
    end)
  end

  def kill_player(room_id, pid) do
    Agent.update(@name, GlobalState, :move_player_to_spectators, [room_id, pid])
  end

  def reset do
    Agent.update(@name, fn _state -> %{} end)
  end

  def get(room_id) do
    Agent.get(@name, fn state ->
      Map.get(state, room_id)
    end)
  end

  def getRooms() do
    Agent.get(@name, fn state ->
      Map.keys(state)
    end)
  end

  def move_player_to_spectators(state, room_id, pid) do
    new_data =
      Map.get(state, room_id)
      |> Map.update(:players, [], fn old_list ->
        old_list -- [pid]
      end)
      |> Map.update(:dead, [pid], fn old_list ->
        old_list ++ [pid]
      end)

    Map.update!(state, room_id, fn _old_state ->
      new_data
    end)
  end
end
