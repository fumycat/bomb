defmodule ErlDictTest do
  use ExUnit.Case

  test "word exists" do
    assert Services.Dict.check("котик") == true
  end

  test "word does not exists" do
    assert Services.Dict.check("хихикот") == false
  end

end
