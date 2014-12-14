defmodule ExNihilo.EventStore do

  use GenServer

  def start_link(backend, backend_opts) do
    GenServer.start_link(__MODULE__, [backend, backend_opts], name: :event_store_proxy)
  end

  def init([backend_mod, backend_opts]) do
    {:ok, backend_state} = backend_mod.init(backend_opts)

    {:ok, {backend_mod, backend_state}}
  end

  def handle_cast({:store, uuid, event}, {backend_mod, backend_state}) do
    backend_state = backend_mod.store(backend_state, uuid, event)
    {:noreply, {backend_mod, backend_state}}
  end


  def handle_call({:fetch, uuid}, _from, state = {backend_mod, backend_state}) do
    {:ok, events} = backend_mod.fetch(backend_state, uuid)
    { :reply, events, state }
  end

  def store(uuid, event) do
    GenServer.cast(:event_store_proxy, {:store, uuid, event})
  end

  # FIXME The agent API assumes that get has no side-effect on the state which
  # may not be true if the state is a connection object or something, the backend
  # may have to manage its own state itself, or we get rid of the agent and use
  # a custom GenServer where we can keep track of the an updated backend state
  def fetch(uuid) do
    GenServer.call(:event_store_proxy, {:fetch, uuid})
  end
end
