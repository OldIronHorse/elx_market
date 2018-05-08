defmodule PricedItem do
  @enforce_keys [:name, :price]
  defstruct [:name, :price]
end

defmodule DiscountedItem do
  @enforce_keys [:items, :saving, :price]
  defstruct [:items, :saving, :price]
end

defmodule Receipt do
  @enforce_keys [:items, :saving, :total]
  defstruct [:items, :saving, :total]

  def make(basket, prices, rules) do
    {full_priced_items, discounted_items} =
      Enum.reduce(rules, {ElxMarket.price_basket(basket, prices), []}, fn rule,
                                                                          {full_price_items,
                                                                           discounted_items} ->
        apply(rule, [full_price_items, discounted_items])
      end)

    discounted_basket = Enum.concat(full_priced_items, discounted_items)

    %Receipt{
      items: discounted_basket,
      saving: Enum.reduce(discounted_items, 0, fn item, saving -> saving + item.saving end),
      total: Enum.reduce(discounted_basket, 0, fn item, total -> total + item.price end)
    }
  end

  def to_string(receipt = %Receipt{}) do
    Enum.concat(receipt.items, [
      "\nTotal saving: -£#{to_gbp_string(receipt.saving)}",
      "Total: £#{to_gbp_string(receipt.total)}\n"
    ])
    |> Enum.reduce([], fn item, lines -> item_to_lines(lines, item) end)
    |> Enum.reverse()
    |> Enum.reduce(fn line, text -> "#{text}\n#{line}" end)
  end

  def item_to_lines(lines, item = %PricedItem{}) do
    ["#{item.name}: £#{to_gbp_string(item.price)}" | lines]
  end

  def item_to_lines(lines, item = %DiscountedItem{}) do
    [
      "Multibuy saving: -£#{to_gbp_string(item.saving)}"
      | Enum.reduce(item.items, lines, fn i, l -> item_to_lines(l, i) end)
    ]
  end

  def item_to_lines(lines, item) do
    [item | lines]
  end

  def to_gbp_string(price) do
    :io_lib.format("~.2f", [price]) |> Kernel.to_string()
  end
end

defmodule ElxMarket do
  @moduledoc """
  Supermarket basket discounting
  """

  def price_basket(basket, prices) do
    Enum.map(basket, fn item -> %PricedItem{name: item, price: prices[item]} end)
  end

  def three_for_two(eligible_item_name, full_price_items, discounted_items) do
    {discounts, undiscounted} =
      make_discounts_three_for_two(
        Enum.filter(full_price_items, fn item -> item.name == eligible_item_name end),
        discounted_items
      )

    {Enum.concat(
       undiscounted,
       Enum.filter(full_price_items, fn item -> item.name != eligible_item_name end)
     ), discounts}
  end

  def rule_three_for_two(eligible_item_name) do
    fn full_price_items, discounted_items ->
      three_for_two(eligible_item_name, full_price_items, discounted_items)
    end
  end

  def make_discounts_three_for_two(eligible_items, discounted_items)
      when length(eligible_items) < 3 do
    {discounted_items, eligible_items}
  end

  def make_discounts_three_for_two(eligible_items, discounted_items) do
    {[make_three_for_two(Enum.take(eligible_items, 3)) | discounted_items],
     Enum.drop(eligible_items, 3)}
  end

  def make_three_for_two([free, paid1, paid2]) do
    %DiscountedItem{
      items: [free, paid1, paid2],
      saving: free.price,
      price: paid1.price + paid2.price
    }
  end
end
