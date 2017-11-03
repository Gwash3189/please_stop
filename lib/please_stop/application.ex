defmodule PleaseStop.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: PleaseStop.Worker.start_link(arg)
      # {PleaseStop.Worker, arg},
      worker(PleaseStop.Store, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PleaseStop.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
