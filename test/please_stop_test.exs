defmodule PleaseStopTest do
  use ExUnit.Case

  describe "when a value is given to init" do
    test "it returns the provided value" do
      value = %{}

      assert(PleaseStop.init(value)) === value
    end
  end


end
