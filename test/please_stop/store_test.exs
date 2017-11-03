defmodule PleaseStop.Store.Test do
  use ExUnit.Case
  doctest PleaseStop.Store

  describe "when starting the store" do
    test "it starts the store with a value" do
      PleaseStop.Store.start_link
      assert :sys.get_state(PleaseStop.Store)
    end
  end

  describe "When a namespace is initialised" do
    test "it is reinitalised after the ttl" do
      ttl = :timer.seconds(1)
      PleaseStop.Store.start_link
      PleaseStop.Store.initialise(
        namespace: :web,
        ttl: ttl,
        limit: 1
      )
      PleaseStop.Store.increment(:web)

      assert PleaseStop.Store.get(:web) === %PleaseStop.Store{
        count: 1,
        ttl: ttl,
        limit: 1,
        namespace: :web
      }

      Process.sleep(ttl)

      assert PleaseStop.Store.get(:web) === %PleaseStop.Store{
        count: 0,
        ttl: ttl,
        limit: 1,
        namespace: :web
      }
    end
  end
end
