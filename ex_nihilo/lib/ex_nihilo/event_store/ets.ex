defmodule ExNihilo.EventStore.Ets do  # this is currently just a copy of InMemory, only to test the pluggability of EventStore

  @table_name  __MODULE__

  def init(_opts) do
    @table_name

    :ets.new(@table_name, [:bag, :named_table])

    {:ok, nil}
  end

  def store(_, uuid, event = {event_name, event_payload}) do

    :ets.insert(@table_name, {uuid, event_name, event_payload})

  end

  def fetch(_, uuid) do

    fetched_events = :ets.lookup(@table_name, uuid)
    |> Enum.map fn({_uuid, event_name, event_payload})->  {event_name, event_payload} end

    {:ok, fetched_events}
  end

end