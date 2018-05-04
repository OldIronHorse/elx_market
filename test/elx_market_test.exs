defmodule ElxMarketTest do
  use ExUnit.Case
  doctest ElxMarket

  test "price a basket" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    assert ElxMarket.price_basket(["soap", "shampoo", "shampoo", "toothpaste", "soap"], prices) ==
             [
               {"soap", 1.5},
               {"shampoo", 2.0},
               {"shampoo", 2.0},
               {"toothpaste", 0.8},
               {"soap", 1.5}
             ]
  end

  test "3 for 2: not triggered, no triplet" do
    assert ElxMarket.three_for_two(
             "shampoo",
             [
               {"soap", 1.5},
               {"shampoo", 2.0},
               {"shampoo", 2.0},
               {"toothpaste", 0.8},
               {"soap", 1.5}
             ],
             []
           ) ==
             {[
                {"soap", 1.5},
                {"shampoo", 2.0},
                {"shampoo", 2.0},
                {"toothpaste", 0.8},
                {"soap", 1.5}
              ], []}
  end
end
