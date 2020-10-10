defmodule YASD.Registry do
  @moduledoc """
  Service registry implementation for YASD.
  """

  use GenServer

  import YASD.Config

  require Logger

  @doc false
  def start_link(_opts) do
    Logger.info("Starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Registers an ip address with a give service name.
  """
  @spec register(String.t(), String.t(), list()) :: :ok | {:error, :bad_ip | :bad_input}
  def register(service, ip, tags \\ [])
  def register(_service, "", _tags), do: {:error, :bad_ip}

  def register(service, ip, tags) when is_binary(ip) and is_list(tags) do
    GenServer.cast(__MODULE__, {:register, service, ip, tags})
  end

  def register(_service, _ip, _tags), do: {:error, :bad_input}

  @doc """
  Lists services registered in this registry.
  """
  @spec list_services :: {:ok, list()}
  def list_services do
    GenServer.call(__MODULE__, :list_services)
  end

  @doc """
  Lists ip of all nodes in a given service without any filters.
  """
  @spec list_nodes(String.t()) :: {:ok, list()} | {:error, :no_registered_nodes}
  def list_nodes(service) do
    GenServer.call(__MODULE__, {:list_nodes, service})
  end

  @doc """
  Lists ip of all nodes which contain the given tags.
  """
  @spec list_nodes(String.t(), list()) :: {:ok, list()} | {:error, :no_registered_nodes}
  def list_nodes(service, tags)

  def list_nodes(service, []), do: list_nodes(service)

  def list_nodes(service, tags) when is_list(tags) do
    GenServer.call(__MODULE__, {:list_nodes_by_tags, service, tags})
  end

  ###
  # GenServer API
  ###

  @impl true
  def init(_opts) do
    schedule_next_janitor()
    {:ok, %{init_at: System.system_time(), services: %{}}}
  end

  @impl true
  def handle_cast({:register, service, ip, tags}, store) do
    node = %{tags: tags, last_heartbeat: System.system_time()}

    service_map =
      (Map.get(store.services, service) || %{})
      |> Map.put(ip, node)

    services = Map.put(store.services, service, service_map)

    {:noreply, Map.put(store, :services, services)}
  end

  @impl true
  def handle_call(:list_services, _from, store) do
    {:reply, {:ok, Map.keys(store.services)}, store}
  end

  @impl true
  def handle_call({:list_nodes, service}, _from, store) do
    case Map.fetch(store.services, service) do
      {:ok, service_map} -> {:reply, {:ok, Map.keys(service_map)}, store}
      :error -> {:reply, {:error, :no_registered_nodes}, store}
    end
  end

  @impl true
  def handle_call({:list_nodes_by_tags, service, tags}, _from, store) do
    case Map.fetch(store.services, service) do
      {:ok, service_map} ->
        nodes =
          service_map
          |> Enum.filter(fn
            {_k, %{tags: nil}} ->
              false

            {_k, %{tags: service_tags}} ->
              Enum.all?(tags, fn t -> t in service_tags end)
          end)
          |> Keyword.keys()

        {:reply, {:ok, nodes}, store}

      :error ->
        {:reply, {:error, :no_registered_nodes}, store}
    end
  end

  @impl true
  def handle_info(:run_janitor, state) do
    Logger.debug("[registry] janitor is called")

    services =
      state.services
      |> Enum.reduce(%{}, fn {service, nodes}, acc_services ->
        nodes =
          Enum.reduce(nodes, %{}, fn {ip, data}, acc ->
            if System.system_time() - data.last_heartbeat > get_heartbeat_timeout() do
              Logger.info("[registery] #{service} => #{ip} has timed-out and removed")
              acc
            else
              Map.put(acc, ip, data)
            end
          end)

        Map.put(acc_services, service, nodes)
      end)

    schedule_next_janitor()

    {:noreply, Map.put(state, :services, services)}
  end

  defp schedule_next_janitor do
    Process.send_after(self(), :run_janitor, get_janitor_sweep_interval() * 1000)
  end
end
