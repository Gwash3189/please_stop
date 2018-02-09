defmodule PleaseStopTest do
  use ExUnit.Case, async: false
  use Plug.Test

  def conn, do: Plug.Test.conn(:get, "/foo")
  def options, do: PleaseStop.Store.new(
    limit: 1,
    ttl: :timer.seconds(1),
    namespace: :name
  )
  def wait, do: :timer.sleep(250)
  def response(conn) do
    sent_resp(conn)
  end
  def call(conn, options) do
    PleaseStop.call(conn, options)
    conn
  end

  setup do
    result = [connection: call(conn(), options())]
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
    test "a 429 is sent", context do
      {status, _, _} = response(context[:connection])

      assert status == 429
    end
  end
end
