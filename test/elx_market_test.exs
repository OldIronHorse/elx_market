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

  test "make receipt: multiple 3 for 2" do
    prices = %{"soap" => 1.5, "shampoo" => 2.0, "toothpaste" => 0.8, "bannana" => 0.8}

    basket = [
      "soap",
      "shampoo",
      "shampoo",
      "toothpaste",
      "soap",
      "shampoo",
      "soap"
    ]

    receipt =
      Receipt.make(basket, prices, [
        ElxMarket.rule_three_for_two("shampoo"),
        ElxMarket.rule_three_for_two("soap")
      ])

    assert receipt == %Receipt{
             items: [
               %PricedItem{name: "toothpaste", price: 0.8},
               %DiscountedItem{
                 items: [
                   %PricedItem{name: "soap", price: 1.5},
                   %PricedItem{name: "soap", price: 1.5},
                   %PricedItem{name: "soap", price: 1.5}
                 ],
                 saving: 1.5,
                 price: 3.0
               },
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
             saving: 3.5,
             total: 7.8
           }
  end

  test "reciept to string" do
    assert Receipt.to_string(%Receipt{
             items: [
               %PricedItem{name: "toothpaste", price: 0.8},
               %DiscountedItem{
                 items: [
                   %PricedItem{name: "soap", price: 1.5},
                   %PricedItem{name: "soap", price: 1.5},
                   %PricedItem{name: "soap", price: 1.5}
                 ],
                 saving: 1.5,
                 price: 3.0
               },
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
             saving: 3.5,
             total: 7.8
           }) == """
           toothpaste: £0.80
           soap: £1.50
           soap: £1.50
           soap: £1.50
           Multibuy saving: -£1.50
           shampoo: £2.00
           shampoo: £2.00
           shampoo: £2.00
           Multibuy saving: -£2.00

           Total saving: -£3.50
           Total: £7.80
           """
  end

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

  test "2 for: not triggered, not enough items" do
    {full_priced, []} =
      ElxMarket.two_for(
        "toothpaste",
        1.0,
        [
          %PricedItem{name: "soap", price: 1.5},
          %PricedItem{name: "shampoo", price: 2.0},
          %PricedItem{name: "shampoo", price: 2.0},
          %PricedItem{name: "toothpaste", price: 0.8},
          %PricedItem{name: "soap", price: 1.5}
        ],
        []
      )

    assert sort(full_priced) ==
             sort([
               %PricedItem{name: "soap", price: 1.5},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "shampoo", price: 2.0},
               %PricedItem{name: "toothpaste", price: 0.8},
               %PricedItem{name: "soap", price: 1.5}
             ])
  end

  test "2 for: simplest" do
    assert ElxMarket.two_for(
             "soap",
             2.0,
             [%PricedItem{name: "soap", price: 1.5}, %PricedItem{name: "soap", price: 1.5}],
             []
           ) ==
             {[],
              [
                %DiscountedItem{
                  items: [
                    %PricedItem{name: "soap", price: 1.5},
                    %PricedItem{name: "soap", price: 1.5}
                  ],
                  saving: 1.0,
                  price: 2.0
                }
              ]}
  end

  test "cheapest free: not triggered preserve discounts" do
    {full_price,
     [
       %DiscountedItem{
         items: [%PricedItem{name: "cheese", price: 1.0}],
         saving: 0.25,
         price: 0.75
       }
     ]} =
      ElxMarket.cheapest_free(
        ["soap", "toothepaste", "conditioner"],
        3,
        [
          %PricedItem{name: "soap", price: 1.5},
          %PricedItem{name: "shampoo", price: 2.0},
          %PricedItem{name: "shampoo", price: 2.0},
          %PricedItem{name: "toothpaste", price: 0.8}
        ],
        [
          %DiscountedItem{
            items: [%PricedItem{name: "cheese", price: 1.0}],
            saving: 0.25,
            price: 0.75
          }
        ]
      )

    assert sort([
             %PricedItem{name: "soap", price: 1.5},
             %PricedItem{name: "shampoo", price: 2.0},
             %PricedItem{name: "shampoo", price: 2.0},
             %PricedItem{name: "toothpaste", price: 0.8}
           ]) == sort(full_price)
  end
end
