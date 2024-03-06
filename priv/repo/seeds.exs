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

alias InvoiceManager.Inventory.Product
alias InvoiceManager.Repo

%Product{name: "Potato", price: 2, stock: 3000, company_id: 1}
|> Repo.insert!()

%Product{name: "Apple", price: 1, stock: 5000, company_id: 1}
|> Repo.insert!()

%Product{name: "Banana", price: 0.5, stock: 6000, company_id: 1}
|> Repo.insert!()

%Product{name: "Milk", price: 3, stock: 2000, company_id: 1}
|> Repo.insert!()

%Product{name: "Eggs", price: 2.5, stock: 1500, company_id: 1}
|> Repo.insert!()

%Product{name: "Bread", price: 2.75, stock: 2500, company_id: 1}
|> Repo.insert!()

%Product{name: "Chicken", price: 5, stock: 1000, company_id: 1}
|> Repo.insert!()

%Product{name: "Beef", price: 7, stock: 800, company_id: 1}
|> Repo.insert!()

%Product{name: "Pasta", price: 1.5, stock: 3500, company_id: 1}
|> Repo.insert!()

%Product{name: "Rice", price: 2.25, stock: 4000, company_id: 1}
|> Repo.insert!()

%Product{name: "Tomato", price: 1.25, stock: 4500, company_id: 1}
|> Repo.insert!()

%Product{name: "Lettuce", price: 1.75, stock: 3000, company_id: 1}
|> Repo.insert!()

%Product{name: "Carrot", price: 1, stock: 4000, company_id: 1}
|> Repo.insert!()

%Product{name: "Onion", price: 1.5, stock: 3500, company_id: 1}
|> Repo.insert!()

%Product{name: "Orange", price: 1.75, stock: 4500, company_id: 1}
|> Repo.insert!()

%Product{name: "Grapes", price: 3.5, stock: 2000, company_id: 1}
|> Repo.insert!()

%Product{name: "Cheese", price: 4, stock: 1800, company_id: 1}
|> Repo.insert!()

%Product{name: "Yogurt", price: 2.25, stock: 3000, company_id: 1}
|> Repo.insert!()

%Product{name: "Cereal", price: 3.75, stock: 2200, company_id: 1}
|> Repo.insert!()

%Product{name: "Salmon", price: 8, stock: 1000, company_id: 1}
|> Repo.insert!()

%Product{name: "Shrimp", price: 10, stock: 700, company_id: 1}
|> Repo.insert!()

%Product{name: "Tuna", price: 5.5, stock: 1200, company_id: 1}
|> Repo.insert!()

%Product{name: "Bacon", price: 6, stock: 900, company_id: 1}
|> Repo.insert!()

%Product{name: "Ham", price: 7.5, stock: 800, company_id: 1}
|> Repo.insert!()

%Product{name: "Sausage", price: 4.5, stock: 1500, company_id: 1}
|> Repo.insert!()

%Product{name: "Butter", price: 2.75, stock: 2500, company_id: 1}
|> Repo.insert!()

%Product{name: "Jam", price: 3.25, stock: 2300, company_id: 1}
|> Repo.insert!()

%Product{name: "Biscuits", price: 1.75, stock: 3200, company_id: 1}
|> Repo.insert!()

%Product{name: "Chips", price: 2.5, stock: 2800, company_id: 1}
|> Repo.insert!()

%Product{name: "Chocolate", price: 2.25, stock: 3300, company_id: 1}
|> Repo.insert!()

%Product{name: "Ice Cream", price: 4.75, stock: 1700, company_id: 1}
|> Repo.insert!()

%Product{name: "Cake", price: 8.5, stock: 1100, company_id: 1}
|> Repo.insert!()

%Product{name: "Cookies", price: 3.5, stock: 2500, company_id: 1}
|> Repo.insert!()

%Product{name: "Juice", price: 2.75, stock: 2900, company_id: 1}
|> Repo.insert!()

%Product{name: "Soda", price: 1.5, stock: 3600, company_id: 1}
|> Repo.insert!()

%Product{name: "Water", price: 1, stock: 5000, company_id: 1}
|> Repo.insert!()

%Product{name: "Beer", price: 5, stock: 1400, company_id: 1}
|> Repo.insert!()

%Product{name: "Wine", price: 12, stock: 600, company_id: 1}
|> Repo.insert!()

%Product{name: "Whiskey", price: 20, stock: 300, company_id: 1}
|> Repo.insert!()

%Product{name: "Vodka", price: 15, stock: 400, company_id: 1}
|> Repo.insert!()

%Product{name: "Tequila", price: 18, stock: 350, company_id: 1}
|> Repo.insert!()

%Product{name: "Rum", price: 10, stock: 550, company_id: 1}
|> Repo.insert!()

%Product{name: "Tea", price: 3, stock: 2500, company_id: 1}
|> Repo.insert!()

%Product{name: "Coffee", price: 5, stock: 2000, company_id: 1}
|> Repo.insert!()

%Product{name: "Sugar", price: 1.5, stock: 3800, company_id: 1}
|> Repo.insert!()

%Product{name: "Flour", price: 2, stock: 3200, company_id: 1}
|> Repo.insert!()

%Product{name: "Salt", price: 1, stock: 4500, company_id: 1}
|> Repo.insert!()

%Product{name: "Pepper", price: 1.25, stock: 4200, company_id: 1}
|> Repo.insert!()

%Product{name: "Olive Oil", price: 6, stock: 1600, company_id: 1}
|> Repo.insert!()

%Product{name: "Vinegar", price: 3.5, stock: 2200, company_id: 1}
|> Repo.insert!()

%Product{name: "Ketchup", price: 2, stock: 2800, company_id: 1}
|> Repo.insert!()

%Product{name: "Mustard", price: 1.75, stock: 3100, company_id: 1}
|> Repo.insert!()

%Product{name: "Mayonnaise", price: 2.5, stock: 2700, company_id: 1}
|> Repo.insert!()

%Product{name: "Soy Sauce", price: 2.25, stock: 2900, company_id: 1}
|> Repo.insert!()

%Product{name: "Hot Sauce", price: 2.75, stock: 2400, company_id: 1}
|> Repo.insert!()

%Product{name: "Pickles", price: 3, stock: 2100, company_id: 1}
|> Repo.insert!()

%Product{name: "Olives", price: 2.5, stock: 2600, company_id: 1}
|> Repo.insert!()

%Product{name: "Canned Beans", price: 1.5, stock: 3400, company_id: 1}
|> Repo.insert!()

%Product{name: "Canned Soup", price: 2.75, stock: 2300, company_id: 1}
|> Repo.insert!()

%Product{name: "Canned Vegetables", price: 2, stock: 3000, company_id: 1}
|> Repo.insert!()

%Product{name: "Peanut Butter", price: 4, stock: 1900, company_id: 1}
|> Repo.insert!()

%Product{name: "Jelly", price: 3, stock: 2200, company_id: 1}
|> Repo.insert!()

%Product{name: "Pasta Sauce", price: 2.5, stock: 2800, company_id: 1}
|> Repo.insert!()

%Product{name: "Ramen", price: 0.75, stock: 5000, company_id: 1}
|> Repo.insert!()

%Product{name: "Instant Noodles", price: 1, stock: 4800, company_id: 1}
|> Repo.insert!()

%Product{name: "Frozen Vegetables", price: 2.25, stock: 3300, company_id: 1}
|> Repo.insert!()

%Product{name: "Frozen Pizza", price: 5, stock: 2100, company_id: 1}
|> Repo.insert!()

%Product{name: "Frozen Dinners", price: 4, stock: 2400, company_id: 1}
|> Repo.insert!()

%Product{name: "Frozen Desserts", price: 3.5, stock: 2700, company_id: 1}
|> Repo.insert!()
