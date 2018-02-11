defmodule PleaseStop do
  import Plug.Conn
  require Logger
  alias PleaseStop.Store

  @moduledoc """
  ## Usage

  To use `PleaseStop` in Phoenix you can use it just like any other plug.

  ```
  scope "/avatars" do
    plug PleaseStop, limit: 5000, ttl: :timer.minutes(1), namespace: :avatars

    scope "/something" do
      plug PleaseStop, limit: 5, ttl: :timer.minutes(10), namespace: fn (conn) -> conn.assigns.something end
    end
  end
  ```

  ### Options

  The options provided to `PleaseStop` are detailed below

  * `limit`: The maximum number of requests you'll accept within the provided `ttl`.
  * `ttl`: The amount of time before the request count is set back to `0`. If the `limit` is reached within this `ttl`, a `429` will be returned and the `conn` will be halted.
  * `namespace`: The namespace where your rate limiting information is kept.
                 This namespace can be a static value or a function that receives the current connection
  """

  def init(options) do
    options
  end

  def call(conn, options) do
    case Store.over_limit?(conn, options) do
      false ->
        # increment number for that namespace
        Store.increment(conn, options)

      true ->
        options.on_overage && options.on_overage.(conn)

        conn
        |> send_resp(429, "")
        |> halt
    end

    conn
  end
end
