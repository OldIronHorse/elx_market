defmodule ElxMarket do
  @moduledoc """
  Supermarket basket discounting
  """

  defmodule PricedItem do
    defstruct name: nil, price: 0
  end

  def price_basket(basket, prices) do
    Enum.map(basket, fn item -> %PricedItem{name: item, price: prices[item]} end)
  end

  def three_for_two(eligible_item_name, full_price_items, discounted_items) do
    {discounts, undiscounted} =
      make_discounts_three_for_two(
        Enum.filter(full_price_items, fn {name, _price} -> name == eligible_item_name end),
        discounted_items
      )

    {Enum.concat(
       undiscounted,
       Enum.filter(full_price_items, fn {name, _price} -> name != eligible_item_name end)
     ), discounts}
  end

  def make_discounts_three_for_two(eligible_items, discounted_items)
      when length(eligible_items) < 3 do
    {discounted_items, eligible_items}
  end

  def make_discounts_three_for_two(eligible_items, discounted_items) do
    {[make_three_for_two(Enum.take(eligible_items, 3)) | discounted_items],
     Enum.drop(eligible_items, 3)}
  end

  def make_three_for_two([free | paid]) do
    {_name, saving} = free
    {[free | paid], saving, Enum.reduce(paid, 0, fn {_name, price}, total -> total + price end)}
  end
end
