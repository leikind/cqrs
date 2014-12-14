defmodule EntityTest do
  use ExUnit.Case, async: true

  alias ExNihilo.UUID
  alias PotionStore.ShoppingCart

  setup_all do
    if ExNihilo.Supervisor.event_store_started? do
      ExNihilo.Supervisor.terminate_event_store
    end
    ExNihilo.Supervisor.start_event_store(event_store: ExNihilo.EventStore.InMemory, event_store_opts: [])
    {:ok, %{}}
  end


  test "domain object update" do
    cart =
      ShoppingCart.create(UUID.generate)
      |> ShoppingCart.add_item("Artline 100N")
      |> ShoppingCart.add_item("Coke classic")
      |> ShoppingCart.add_item("Coke zero")

    assert cart.uuid
    assert ["Artline 100N", "Coke classic", "Coke zero"] == cart.items
  end

  test "rebuilding an entity from the event store" do

    uuid = UUID.generate

    cart =
      ShoppingCart.create(uuid)
      |> ShoppingCart.add_item("Artline 100N")
      |> ShoppingCart.add_item("Coke classic")
      |> ShoppingCart.add_item("Coke zero")

    rebuilt_cart = PotionStore.ShoppingCart.get(uuid)

    assert rebuilt_cart == cart
  end

end
