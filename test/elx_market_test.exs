defmodule ElxMarketTest do
  use ExUnit.Case
  import Enum
  doctest ElxMarket

  # TODO: use records or dictionaries for items?

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
    assert ElxMarket.three_for_two(
             "shampoo",
             [
               {"soap", 1.5},
               {"shampoo", 2.0},
               {"shampoo", 2.0},
               {"toothpaste", 0.8},
               {"shampoo", 2.0},
               {"soap", 1.5}
             ],
             []
           ) ==
             {[
                {"soap", 1.5},
                {"toothpaste", 0.8},
                {"soap", 1.5}
              ],
              [
                {[{"shampoo", 2.0}, {"shampoo", 2.0}, {"shampoo", 2.0}], 2.0, 4.0}
              ]}
  end
end
