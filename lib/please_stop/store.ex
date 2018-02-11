defmodule PleaseStop.Store do
  use GenServer

  defstruct limit: 0,
            ttl: :timer.minutes(1),
            namespace: nil,
            count: 0,
            on_overage: nil

  @doc """
  Creates a `PleaseStop.Store` struct from a keyword list of `limit`, `ttl`, and `namespace`

  """
  def new(list) do
    struct = %PleaseStop.Store{}

    limit = Keyword.get(list, :limit)
    ttl = Keyword.get(list, :ttl)
    namespace = Keyword.get(list, :namespace)
    on_overage = Keyword.get(list, :on_overage)

    namespace =
      case is_function(namespace) do
        true -> namespace
        false -> fn _ -> namespace end
      end

    Map.merge(struct, %{
      limit: limit,
      ttl: ttl,
      namespace: namespace,
      on_overage: on_overage
    })
  end

  @doc "the pool name used in poolboy"
  def pool_name, do: :store_worker

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  @doc "increments the `count` stored against the `namespace`"
  def increment(conn, options) do
    transaction(:cast, {:increment, conn, options})
  end

  @doc """
  returns a boolean indicating wether the `namespace`
  is over their specified `limit` or not"
  """
  def over_limit?(conn, options) do
    transaction(:call, {:over_limit, conn, options})
  end

  def handle_cast({:increment, conn, options}, state) do
    store = get(conn, options)
    put(conn, options, Map.merge(store, %{count: 1 + store.count}))
    {:noreply, state}
  end

  def handle_call({:over_limit, conn, options}, _from, state) do
    %{count: count, limit: limit} = get(conn, options)
    {:reply, count >= limit, state}
  end

  defp transaction(kind, term) do
    :poolboy.transaction(pool_name(), fn pid -> apply(GenServer, kind, [pid, term]) end)
  end

  defp get(conn, options) do
    id = options.namespace.(conn)
    ConCache.get(:please_stop_cache, id) || options
  end

  defp put(conn, options, value) do
    id = options.namespace.(conn)
    ConCache.put(:please_stop_cache, id, value)
  end
end
