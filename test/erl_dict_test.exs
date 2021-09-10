defmodule ErlDictTest do
  use ExUnit.Case

  test "word exists" do
    assert :dict_server.check("котик") == true
  end

  test "word does not exists" do
    assert :dict_server.check("хихикот") == false
  end

end
