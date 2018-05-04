defmodule ElxMarketTest do
  use ExUnit.Case
  import Enum
  doctest ElxMarket

  test "price a basket" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    assert ElxMarket.price_basket(["soap", "shampoo", "shampoo", "toothpaste", "soap"], prices) ==
             [
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "soap", price: 1.5}
             ]
  end

  test "make receipt: no discounts" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    basket = [
      "soap",
      "shampoo",
      "shampoo",
      "toothpaste",
      "shampoo",
      "soap"
    ]

    receipt = Receipt.make(basket, prices, [])

    assert receipt == %Receipt{
             items: [
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "soap", price: 1.5}
             ],
             saving: 0,
             total: 9.8
           }
  end

  test "make receipt: 3 for 2 only" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    basket = [
      "soap",
      "shampoo",
      "shampoo",
      "toothpaste",
      "shampoo",
      "soap"
    ]

    receipt = Receipt.make(basket, prices, [ElxMarket.rule_three_for_two("shampoo")])

    assert receipt == %Receipt{
             items: [
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "soap", price: 1.5},
               %DiscountedItem{
                 items: [
                   %PricedItem{name: "shampoo", price: 2.0},
                   %PricedItem{name: "shampoo", price: 2.0},
                   %PricedItem{name: "shampoo", price: 2.0}
                 ],
                 saving: 2.0,
                 price: 4.0
               }
             ],
             saving: 2.0,
             total: 7.8
           }
  end

  # TODO: make receipt
  # TODO: make receipt string

  test "3 for 2: not triggered, no triplet" do
    assert ElxMarket.three_for_two(
             "shampoo",
             sort([
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "soap", price: 1.5}
             ]),
             []
           ) ==
             {sort([
                %PricedItem{name: "soap", price: 1.5},
                %PricedItem{name: "shampoo", price: 2.0},
                %PricedItem{name: "shampoo", price: 2.0},
                %PricedItem{name: "toothpaste", price: 0.8},
                %PricedItem{name: "soap", price: 1.5}
              ]), []}
  end

  test "3 for 2: simplest" do
    priced_basket = [
      %PricedItem{name: "soap", price: 1.5},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "toothpaste", price: 0.8},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "soap", price: 1.5}
    ]

    {full_price_items, discounted_items} = ElxMarket.three_for_two("shampoo", priced_basket, [])

    assert sort(full_price_items) ==
             sort([
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "soap", price: 1.5}
             ])

    assert discounted_items == [
             %DiscountedItem{
               items: [
                 %PricedItem{name: "shampoo", price: 2.0},
                 %PricedItem{name: "shampoo", price: 2.0},
                 %PricedItem{name: "shampoo", price: 2.0}
               ],
               saving: 2.0,
               price: 4.0
             }
           ]
  end

  test "3 for 2: one and a bit matches" do
    priced_basket = [
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "soap", price: 1.5},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "toothpaste", price: 0.8},
      %PricedItem{name: "shampoo", price: 2.0},
      %PricedItem{name: "soap", price: 1.5},
      %PricedItem{name: "shampoo", price: 2.0}
    ]

    {full_price_items, discounted_items} = ElxMarket.three_for_two("shampoo", priced_basket, [])

    assert sort(full_price_items) ==
             sort([
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "soap", price: 1.5}
             ])

    assert discounted_items ==
             [
               %DiscountedItem{
                 items: [
                   %PricedItem{name: "shampoo", price: 2.0},
                   %PricedItem{name: "shampoo", price: 2.0},
                   %PricedItem{name: "shampoo", price: 2.0}
                 ],
                 saving: 2.0,
                 price: 4.0
               }
             ]
  end
end
