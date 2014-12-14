ExUnit.start()


# Listeners

defmodule CartItemCounter do
  use GenEvent

  def init(_opts) do
    {:ok, HashDict.new}
  end

  def handle_event({{:item_added, %{item: item}}, _uuid}, counters) do
    counters = Dict.update(counters, item, 1, fn(count) -> count + 1 end)
    {:ok, counters}
  end

  def handle_event({{:item_removed, %{item: item}}, _uuid}, counters) do
    counters = Dict.update!(counters, item, fn(count) -> count - 1 end)
    {:ok, counters}
  end

  def handle_event(_, counters) do
    {:ok, counters}
  end

  def handle_call(:current_state, counters) do
    {:ok, counters, counters}
  end

end

defmodule EventDebugger do
  use GenEvent

  def init(_opts) do
    {:ok, 0}
  end

  def handle_event({event, uuid}, counter) do
    counter = counter + 1
    IO.puts "EventDebugger: Event##{counter} #{inspect event}, UUID: #{inspect uuid}"
    {:ok, counter}
  end

end


defmodule PotionStore do
  defmodule ShoppingCart do

    use ExNihilo.Entity, fields: [items: []]

    def create(uuid) do
      event = {:cart_created, %{uuid: uuid}}
      cart = new()
      trigger(cart, event)
    end

    def add_item(cart, item) do
      event = {:item_added, %{item: item}}
      trigger(cart, event)
    end

    def remove_item(cart, item) do
      event = {:item_removed, %{item: item}}
      trigger(cart, event)
    end

    def apply(cart, {:cart_created, %{uuid: uuid}}) do
      %{cart | uuid: uuid}
    end

    def apply(cart, {:item_added, %{item: item}}) do
      %{cart | items: cart.items ++ [item]}
    end

    def apply(cart, {:item_removed, %{item: item}}) do
      %{cart | items: List.delete(cart.items, item)}
    end
  end

end