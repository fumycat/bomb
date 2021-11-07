defmodule ErlDictTest do
  use ExUnit.Case

  test "word exists" do
    assert Dictionary.check("котик") == true
  end

  test "word does not exists" do
    assert Dictionary.check("хихикот") == false
  end

end
