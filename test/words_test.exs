defmodule WordsTest do
  use ExUnit.Case

  test "words order" do
    list = File.read!("cfg/words.txt") |> String.split()
    sorted = Enum.sort(list)
    assert list == sorted
  end
end
