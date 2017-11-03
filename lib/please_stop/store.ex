defmodule PleaseStop.Store do
  use GenServer
  @moduledoc false

  defstruct [
    limit: 0,
    ttl: :timer.minutes(1),
    namespace: nil,
    count: 0
  ]

  @type options_list :: [
    limit: integer,
    ttl: integer,
    namespace: atom,
    count: integer
  ]

  @doc """
  Transforms an options list into a `%PleaseStop.Store{}`

  ## Examples
      iex> PleaseStop.Store.new(limit: 5, ttl: :timer.seconds(1), namespace: :web)
      %PleaseStop.Store{
        limit: 5,
        ttl: :timer.seconds(1),
        namespace: :web,
        count: 0
      }
  """
  @spec new(options_list) :: %PleaseStop.Store{}
  def new(options_list) do
    extract_options(options_list)
  end

  @doc """
  Starts the cache with an empty map as the state.
  """
  @spec start_link() :: {:ok, pid}
  def start_link do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Increments the `count` on the namespace

  ## Examples

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(namespace: :web, limit: 1, ttl: :timer.seconds(1))
      iex> PleaseStop.Store.increment(:web)
      iex> :sys.get_state(PleaseStop.Store)
      %{
        web: %PleaseStop.Store{
          count: 1,
          limit: 1,
          namespace: :web,
          ttl: :timer.seconds(1)
        }
      }
  """
  @spec increment(atom) :: :ok
  def increment(namespace) do
    GenServer.cast(__MODULE__, {:increment, namespace})
  end

  @doc """
  Gets the current state of the provided namespace

  ## Examples

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(namespace: :web, limit: 1, ttl: :timer.seconds(1))
      iex> PleaseStop.Store.get(:web)
      %PleaseStop.Store{
        count: 0,
        limit: 1,
        namespace: :web,
        ttl: :timer.seconds(1)
      }
  """
  @spec get(atom) :: map
  def get(namespace) do
    GenServer.call(__MODULE__, {:get, namespace})
  end

  @spec handle_call({:get, atom}, pid, map) :: {:reply, map}
  def handle_call({:get, namespace}, _from, state) do
    {:reply, Map.get(state, namespace), state}
  end

  @doc """
  Returns true of false depending if the
  provided namespace is over their specified limit

  ## Examples

      ### Under the specifid limit

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(namespace: :web, limit: 1, ttl: :timer.seconds(1))
      iex> PleaseStop.Store.over_limit?(:web)
      false

      ### Over the specifid limit

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(namespace: :web, limit: 1, ttl: :timer.seconds(1))
      iex> PleaseStop.Store.increment(:web)
      iex> PleaseStop.Store.over_limit?(:web)
      true
  """
  @spec over_limit?(atom) :: true | false
  def over_limit?(namespace) do
    %{count: count, limit: limit} = get(namespace)
    count >= limit
  end

  @doc """
  Initialises the the provided namespace with a `%PleaseStop.Store{}`

  ## Examples

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(%PleaseStop.Store{count: 0, limit: 1, namespace: :web, timeout: :timer.seconds(1)})
      iex> :sys.get_state(PleaseStop.Store)
      %{
        web: %PleaseStop.Store{
          count: 0,
          limit: 1,
          namespace: :web,
          ttl: :timer.seconds(1)
        }
      }
  """
  @spec initialise(%PleaseStop.Store{}) :: :ok
  def initialise(%PleaseStop.Store{} = parsed_options) do
    GenServer.cast(__MODULE__, {:initialise, parsed_options})
    parsed_options
  end

  @doc """
  Initialises the the provided namespace with a `%PleaseStop.Store{}`

  ## Examples

      iex> PleaseStop.Store.start_link
      iex> PleaseStop.Store.initialise(namespace: :web, limit: 1, ttl: :timer.seconds(1))
      iex> :sys.get_state(PleaseStop.Store)
      %{
        web: %PleaseStop.Store{
          count: 0,
          limit: 1,
          namespace: :web,
          ttl: :timer.seconds(1)
        }
      }
  """
  @spec initialise(options_list) :: :ok
  def initialise(options) do
    options |> new |> initialise
  end

  @spec handle_cast({:increment, atom}, map) :: {:noreply, map}
  def handle_cast({:increment, namespace}, state) do
    value = state[namespace].count + 1
    new_state = Map.put(state, namespace, %{state[namespace] | count: value})

    {:noreply, new_state}
  end

  @spec handle_cast({:initialise, %PleaseStop.Store{}}, map) :: {:noreply, map}
  def handle_cast({:initialise, parsed_options}, state) do
    new_state = initialise_namespace(parsed_options, state)

    {:noreply, new_state}
  end

  @doc """
  Handles the message sent by reinitialise_after/2
  """
  @spec handle_info({:initialise, %PleaseStop.Store{}}, map) :: {:noreply, map}
  def handle_info({:initialise, parsed_options}, state) do
    handle_cast({:initialise, parsed_options}, state)
  end

  defp initialise_namespace(parsed_options, state) do
    reinitialise_after(parsed_options)
    Map.put(
      state,
      parsed_options.namespace,
      parsed_options
    )
  end

  defp reinitialise_after(%PleaseStop.Store{ttl: ttl} = parsed_options) do
    Process.send_after(__MODULE__, {:initialise, parsed_options}, ttl)
  end

  defp extract_options(options_list) do
    %PleaseStop.Store{
      limit: Keyword.get(options_list, :limit),
      ttl: Keyword.get(options_list, :ttl),
      namespace: Keyword.get(options_list, :namespace),
    }
  end
end
