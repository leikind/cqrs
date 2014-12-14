defmodule ExNihilo.Supervisor do
  use Supervisor

  @sup_name __MODULE__

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: @sup_name)
  end

  def init([]) do

    children = [worker(ExNihilo.EventBus, [])]

    opts = [strategy: :one_for_one]

    supervise(children, opts)
  end

  def start_event_store(event_store: backend, event_store_opts: opts) do
    Supervisor.start_child(@sup_name, worker(ExNihilo.EventStore, [backend, opts]) )
  end

  def terminate_event_store do
    Supervisor.terminate_child(@sup_name, ExNihilo.EventStore)
    Supervisor.delete_child(@sup_name, ExNihilo.EventStore)
  end

  def event_store_started? do
    children
    |> Enum.any?(fn({mod, _, :worker, _}) -> mod == ExNihilo.EventStore end)
  end

  def event_store_child_spec_present? do
    children
    |> Enum.any?(fn({mod, _, _, _}) -> mod == ExNihilo.EventStore end)
  end

  defp children, do: Supervisor.which_children(@sup_name)


end
