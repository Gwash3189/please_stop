defmodule PleaseStopTest do
  use ExUnit.Case
  doctest PleaseStop

  test "greets the world" do
    assert PleaseStop.hello() == :world
  end
end
