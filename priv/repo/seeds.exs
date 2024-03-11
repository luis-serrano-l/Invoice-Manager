# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     InvoiceManager.Repo.insert!(%InvoiceManager.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias InvoiceManager.Accounts
alias InvoiceManager.Business
alias InvoiceManager.Inventory.Product
alias InvoiceManager.Repo

now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

{:ok, user} =
  Accounts.register_user(%{
    "email" => "test@gmail.com",
    "password" => "123412341234",
    "name" => "Luis",
    "last_name" => "Serratest",
    "is_admin" => true
  })

{:ok, company} =
  Business.create_company(%{
    "name" => "Mercaluis",
    "contact_email" => "test@gmail.com",
    "address" => "Sesame Street, 3",
    "contact_phone" => "+34 12341234",
    "fiscal_number" => "010101"
  })

Accounts.update_user(user, %{"company_id" => company.id})

products =
  [
    %{
      name: "Potato",
      price: 0.9,
      stock: 3000,
      sku: 0,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Apple",
      price: 1,
      stock: 5000,
      sku: 1,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Banana",
      price: 0.5,
      stock: 6000,
      sku: 2,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Milk",
      price: 3,
      stock: 2000,
      sku: 3,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Eggs",
      price: 2.5,
      stock: 1500,
      sku: 4,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Bread",
      price: 2.75,
      stock: 2500,
      sku: 5,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Chicken",
      price: 5,
      stock: 1000,
      sku: 6,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Beef",
      price: 7,
      stock: 800,
      sku: 7,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Pasta",
      price: 1.5,
      stock: 3500,
      sku: 8,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Rice",
      price: 2.25,
      stock: 4000,
      sku: 9,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Tomato",
      price: 1.25,
      stock: 4500,
      sku: 10,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Lettuce",
      price: 1.75,
      stock: 3000,
      sku: 11,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Carrot",
      price: 1,
      stock: 4000,
      sku: 12,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Onion",
      price: 1.5,
      stock: 3500,
      sku: 13,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Orange",
      price: 1.75,
      stock: 4500,
      sku: 14,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Grapes",
      price: 3.5,
      stock: 2000,
      sku: 15,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Cheese",
      price: 4,
      stock: 1800,
      sku: 16,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Yogurt",
      price: 2.25,
      stock: 3000,
      sku: 17,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Cereal",
      price: 3.75,
      stock: 2200,
      sku: 18,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Salmon",
      price: 8,
      stock: 1000,
      sku: 19,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Shrimp",
      price: 10,
      stock: 700,
      sku: 20,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Tuna",
      price: 5.5,
      stock: 1200,
      sku: 21,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Bacon",
      price: 6,
      stock: 900,
      sku: 22,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Ham",
      price: 7.5,
      stock: 800,
      sku: 23,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Sausage",
      price: 4.5,
      stock: 1500,
      sku: 24,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Butter",
      price: 2.75,
      stock: 2500,
      sku: 25,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Jam",
      price: 3.25,
      stock: 2300,
      sku: 26,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Biscuits",
      price: 1.75,
      stock: 3200,
      sku: 27,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Chips",
      price: 2.5,
      stock: 2800,
      sku: 28,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Chocolate",
      price: 2.25,
      stock: 3300,
      sku: 29,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Ice Cream",
      price: 4.75,
      stock: 1700,
      sku: 30,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Cake",
      price: 8.5,
      stock: 1100,
      sku: 31,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Cookies",
      price: 3.5,
      stock: 2500,
      sku: 32,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Juice",
      price: 2.75,
      stock: 2900,
      sku: 33,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Soda",
      price: 1.5,
      stock: 3600,
      sku: 34,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Water",
      price: 1,
      stock: 5000,
      sku: 35,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Beer",
      price: 5,
      stock: 1400,
      sku: 36,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Wine",
      price: 12,
      stock: 600,
      sku: 37,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Whiskey",
      price: 20,
      stock: 300,
      sku: 38,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Vodka",
      price: 15,
      stock: 400,
      sku: 39,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Tequila",
      price: 18,
      stock: 350,
      sku: 40,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Rum",
      price: 10,
      stock: 550,
      sku: 41,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Tea",
      price: 3,
      stock: 2500,
      sku: 42,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Coffee",
      price: 5,
      stock: 2000,
      sku: 43,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Sugar",
      price: 1.5,
      stock: 3800,
      sku: 44,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Flour",
      price: 2,
      stock: 3200,
      sku: 45,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Salt",
      price: 1,
      stock: 4500,
      sku: 46,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Pepper",
      price: 1.25,
      stock: 4200,
      sku: 47,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Olive Oil",
      price: 6,
      stock: 1600,
      sku: 48,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Vinegar",
      price: 3.5,
      stock: 2200,
      sku: 49,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Ketchup",
      price: 2,
      stock: 2800,
      sku: 50,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Mustard",
      price: 1.75,
      stock: 3100,
      sku: 51,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Mayonnaise",
      price: 2.5,
      stock: 2700,
      sku: 52,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Soy Sauce",
      price: 2.25,
      stock: 2900,
      sku: 53,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Hot Sauce",
      price: 2.75,
      stock: 2400,
      sku: 54,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Pickles",
      price: 3,
      stock: 2100,
      sku: 55,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Olives",
      price: 2.5,
      stock: 2600,
      sku: 56,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Canned Beans",
      price: 1.5,
      stock: 3400,
      sku: 57,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Canned Soup",
      price: 2.75,
      stock: 2300,
      sku: 58,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Canned Vegetables",
      price: 2,
      stock: 3000,
      sku: 59,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Peanut Butter",
      price: 4,
      stock: 1900,
      sku: 60,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Jelly",
      price: 3,
      stock: 2200,
      sku: 61,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Pasta Sauce",
      price: 2.5,
      stock: 2800,
      sku: 62,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Ramen",
      price: 0.75,
      stock: 5000,
      sku: 63,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Instant Noodles",
      price: 1,
      stock: 4800,
      sku: 64,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Frozen Vegetables",
      price: 2.25,
      stock: 3300,
      sku: 65,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Frozen Pizza",
      price: 5,
      stock: 2100,
      sku: 66,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Frozen Dinners",
      price: 4,
      stock: 2400,
      sku: 67,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    },
    %{
      name: "Frozen Desserts",
      price: 3.5,
      stock: 2700,
      sku: 68,
      company_id: company.id,
      updated_at: now,
      inserted_at: now
    }
  ]
  |> Enum.map(fn product ->
    if is_integer(product.price) do
      Map.put(product, :price, product.price * 1.0)
    else
      product
    end
  end)

Repo.insert_all(Product, products)
