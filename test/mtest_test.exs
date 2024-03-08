defmodule MtestTest do
  use ExUnit.Case
  doctest Mtest

  test "greets the world" do
    assert Mtest.hello() == :world
  end
end
