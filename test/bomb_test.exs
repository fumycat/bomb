defmodule BombTest do
  use ExUnit.Case
  doctest Bomb

  test "greets the world" do
    assert Bomb.hello() == :world
  end
end
