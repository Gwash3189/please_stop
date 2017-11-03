# PleaseStop

A rate limiter plug for Phoenix.

## Installation

[Documentation](https://hex.pm/docs/publish).

the package can be installed by adding `please_stop` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:please_stop, "~> 1.0.0"}
  ]
end
```

## Usage

To use `PleaseStop` in Phoenix you can use it just like any other plug.

```
scope "/avatars" do
  plug PleaseStop, limit: 5000, ttl: :timer.minutes(1), namespace: :avatars

  scope "/something" do
    plug PleaseStop, limit: 5, ttl: :timer.minutes(10), namespace: :something
  end
end
```

### Options

The options provided to `PleaseStop` are detailed below

* `limit`: The maximum number of requests you'll accept within the provided `ttl`.
* `ttl`: The amount of time before the request count is set back to `0`. If the `limit` is reached within this `ttl`, a `429` will be returned and the `conn` will be halted.
* `namespace`: The namespace where your rate limiting information is kept.

