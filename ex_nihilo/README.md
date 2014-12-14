ExNihilo
========

A CQRS and Event Sourcing experiment in Elixir

The client application should explicilty start the correct event store, for example:

  ExNihilo.Supervisor.start_event_store(event_store: ExNihilo.EventStore.InMemory, event_store_opts: [])
