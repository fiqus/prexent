defmodule Prexent.NewTest do
  use ExUnit.Case
  doctest Prexent.New

  test "greets the world" do
    assert Prexent.New.hello() == :world
  end
end
