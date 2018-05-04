defmodule ElxMarketTest do
  use ExUnit.Case
  import Enum
  doctest ElxMarket

  test "price a basket" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    assert ElxMarket.price_basket(["soap", "shampoo", "shampoo", "toothpaste", "soap"], prices) ==
             [
               %ElxMarket.PricedItem{name: "soap", price: 1.5},
               %ElxMarket.PricedItem{name: "shampoo", price: 2.0},
               %ElxMarket.PricedItem{name: "shampoo", price: 2.0},
               %ElxMarket.PricedItem{name: "toothpaste", price: 0.8},
               %ElxMarket.PricedItem{name: "soap", price: 1.5}
             ]
  end

  #TODO: make receipt

  test "3 for 2: not triggered, no triplet" do
    assert ElxMarket.three_for_two(
             "shampoo",
             sort([
               {"soap", 1.5},
               {"shampoo", 2.0},
               {"shampoo", 2.0},
               {"toothpaste", 0.8},
               {"soap", 1.5}
             ]),
             []
           ) ==
             {sort([
                {"soap", 1.5},
                {"shampoo", 2.0},
                {"shampoo", 2.0},
                {"toothpaste", 0.8},
                {"soap", 1.5}
              ]), []}
  end

  test "3 for 2: simeplest" do
    priced_basket = [
      {"soap", 1.5},
      {"shampoo", 2.0},
      {"shampoo", 2.0},
      {"toothpaste", 0.8},
      {"shampoo", 2.0},
      {"soap", 1.5}
    ]
    
    {full_price_items, discounted_items} = ElxMarket.three_for_two("shampoo", priced_basket, [])
    assert sort(full_price_items) ==
             sort([
                {"soap", 1.5},
                {"toothpaste", 0.8},
                {"soap", 1.5}
              ])
    assert discounted_items == [{[{"shampoo", 2.0}, {"shampoo", 2.0}, {"shampoo", 2.0}], 2.0, 4.0}]
  end

  test "3 for 2: one and a bit matches" do
    priced_basket = [
      {"shampoo", 2.0},
      {"soap", 1.5},
      {"shampoo", 2.0},
      {"shampoo", 2.0},
      {"toothpaste", 0.8},
      {"shampoo", 2.0},
      {"soap", 1.5},
      {"shampoo", 2.0}
    ]

    {full_price_items, discounted_items} = ElxMarket.three_for_two("shampoo", priced_basket, [])

    assert sort(full_price_items) ==
             sort([
               {"soap", 1.5},
               {"toothpaste", 0.8},
               {"shampoo", 2.0},
               {"shampoo", 2.0},
               {"soap", 1.5}
             ])

    assert discounted_items ==
             [
               {[{"shampoo", 2.0}, {"shampoo", 2.0}, {"shampoo", 2.0}], 2.0, 4.0}
             ]
  end
end
