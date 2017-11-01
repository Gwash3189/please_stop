defmodule PleaseStop.Store do
  use Agent

  def start_link do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def increment(namespace) do
    Agent.update(__MODULE__, fn(state) ->
      Map.put(state, namespace, state[namespace] + 1)
    end)
  end

  def decrement(namespace) do
    Agent.update(__MODULE__, fn(state) ->
      Map.put(state, namespace, state[namespace] - 1)
    end)
  end

  def clear(namespace) do
    Agent.update(__MODULE__, fn(state) ->
      Map.put(state, namespace, 0)
    end)
  end

  def initialise(namespace), do: clear(namespace)
end
