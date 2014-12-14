defmodule ExNihiloEtsTest do
  use ExUnit.Case

  setup_all do
    if ExNihilo.Supervisor.event_store_started? do
      ExNihilo.Supervisor.terminate_event_store
    end
    ExNihilo.Supervisor.start_event_store(event_store: ExNihilo.EventStore.Ets, event_store_opts: [])
    {:ok, %{}}
  end

  test "the truth" do
    ExNihilo.EventBus.add_listener(CartItemCounter)
    ExNihilo.EventBus.add_listener(EventDebugger)

    cart_uuid = ExNihilo.UUID.generate

    assert ExNihilo.EventStore.size == 0

    cart =
      PotionStore.ShoppingCart.create(cart_uuid)
      |> PotionStore.ShoppingCart.add_item("Artline 100N")
      |> PotionStore.ShoppingCart.add_item("Coke classic")
      |> PotionStore.ShoppingCart.add_item("Coke zero")

    assert ExNihilo.EventStore.size == 4

    IO.inspect cart

    IO.puts "====================="

    cart = PotionStore.ShoppingCart.get(cart_uuid)
    IO.inspect cart

    IO.puts "====================="

    cart2 =
      PotionStore.ShoppingCart.create(ExNihilo.UUID.generate)
      |> PotionStore.ShoppingCart.add_item("Coke classic")
      |> PotionStore.ShoppingCart.add_item("Coke classic")
      |> PotionStore.ShoppingCart.add_item("Doppio espresso")
      |> PotionStore.ShoppingCart.remove_item("Coke classic")

    IO.inspect cart2

    counter = ExNihilo.EventBus.current_state(CartItemCounter)
    IO.puts "Items currently added to carts: #{inspect counter}"

    # TODO make sure we execute this even if test fails
    ExNihilo.EventBus.remove_listener(CartItemCounter)
    ExNihilo.EventBus.remove_listener(EventDebugger)
  end
end
