defmodule ElxMarket do
  @moduledoc """
  Supermarket basket discounting
  """

  def price_basket(basket, prices) do
    price_basket(basket, prices, [])
  end

  def price_basket([], _prices, priced_items) do
    Enum.reverse(priced_items)
  end

  def price_basket([item | basket], prices, priced_items) do
    price_basket(basket, prices, [{item, prices[item]} | priced_items])
  end

  def three_for_two(eligible_item_name, full_price_items, discounted_items) do
    {full_price_items, discounted_items}
  end
end
