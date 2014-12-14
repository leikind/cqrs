defmodule ExNihilo.EventStore.Mnesia do  # this is currently just a copy of InMemory, only to test the pluggability of EventStore

  def init(_opts) do
    {:ok, []}
  end

  def store(events, uuid, event) do
    [{uuid, event} | events]
  end

  def fetch(events, uuid) do
    fetched_events =
      events
      |> Enum.filter(fn {event_uuid, _event} -> event_uuid == uuid end)
      |> Enum.map(fn {_, event} -> event end)
      |> Enum.reverse
    {:ok, fetched_events}
  end

end