defmodule PleaseStopTest do
  use Spyanator.Assertions
  use ExUnit.Case, async: false
  use Plug.Test

  def conn, do: Plug.Test.conn(:get, "/foo")

  def options,
    do:
      PleaseStop.Store.new(
        limit: 1,
        ttl: :timer.seconds(1),
        namespace: :name,
        on_overage: &PleaseStopTest.OverageSpy.on_overage(&1)
      )

  def wait, do: :timer.sleep(250)

  def response(conn) do
    sent_resp(conn)
  end

  def call(conn, options) do
    PleaseStop.call(conn, options)
    conn
  end

  defmodule OverageSpy do
    use Spyanator

    def on_overage(_), do: true
  end

  setup do
    opts = options()

    Spyanator.start_link()
    Spyanator.start_spy(OverageSpy)

    result = [connection: call(conn(), opts), options: opts]
    wait()

    result
  end

  describe "when a value is given to init" do
    test "it returns the provided value" do
      value = %{}

      assert PleaseStop.init(value) == value
    end
  end

  describe "when the plug is called" do
    test "it increments a new entry" do
      count = ConCache.get(:please_stop_cache, :name) |> Map.get(:count)

      assert count == 1
    end
  end

  describe "when a namespace is over it's limit" do
    setup do
      opts = options()
      result = [connection: call(conn(), opts), options: opts]
      wait()

      result
    end

    test "a 429 is sent", context do
      {status, _, _} = response(context[:connection])

      assert status == 429
    end

    test "it calls the provided on_overage function" do
      assert OverageSpy |> received(:on_overage) |> at_least(1) |> time
    end
  end
end
