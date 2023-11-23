defmodule InvoiceManager.InventoryTest do
  use InvoiceManager.DataCase

  alias InvoiceManager.Inventory

  describe "companies" do
    alias InvoiceManager.Inventory.Company

    import InvoiceManager.InventoryFixtures

    @invalid_attrs %{address: nil, contact_email: nil, contact_phone: nil, fiscal_number: nil, name: nil}

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Inventory.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Inventory.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{address: "some address", contact_email: "some contact_email", contact_phone: "some contact_phone", fiscal_number: "some fiscal_number", name: "some name"}

      assert {:ok, %Company{} = company} = Inventory.create_company(valid_attrs)
      assert company.address == "some address"
      assert company.contact_email == "some contact_email"
      assert company.contact_phone == "some contact_phone"
      assert company.fiscal_number == "some fiscal_number"
      assert company.name == "some name"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      update_attrs = %{address: "some updated address", contact_email: "some updated contact_email", contact_phone: "some updated contact_phone", fiscal_number: "some updated fiscal_number", name: "some updated name"}

      assert {:ok, %Company{} = company} = Inventory.update_company(company, update_attrs)
      assert company.address == "some updated address"
      assert company.contact_email == "some updated contact_email"
      assert company.contact_phone == "some updated contact_phone"
      assert company.fiscal_number == "some updated fiscal_number"
      assert company.name == "some updated name"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_company(company, @invalid_attrs)
      assert company == Inventory.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Inventory.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Inventory.change_company(company)
    end
  end

  describe "products" do
    alias InvoiceManager.Inventory.Product

    import InvoiceManager.InventoryFixtures

    @invalid_attrs %{name: nil, price: nil, stock: nil}

    test "list_products/0 returns all products" do
      product = product_fixture()
      assert Inventory.list_products() == [product]
    end

    test "get_product!/1 returns the product with given id" do
      product = product_fixture()
      assert Inventory.get_product!(product.id) == product
    end

    test "create_product/1 with valid data creates a product" do
      valid_attrs = %{name: "some name", price: "120.5", stock: 42}

      assert {:ok, %Product{} = product} = Inventory.create_product(valid_attrs)
      assert product.name == "some name"
      assert product.price == Decimal.new("120.5")
      assert product.stock == 42
    end

    test "create_product/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_product(@invalid_attrs)
    end

    test "update_product/2 with valid data updates the product" do
      product = product_fixture()
      update_attrs = %{name: "some updated name", price: "456.7", stock: 43}

      assert {:ok, %Product{} = product} = Inventory.update_product(product, update_attrs)
      assert product.name == "some updated name"
      assert product.price == Decimal.new("456.7")
      assert product.stock == 43
    end

    test "update_product/2 with invalid data returns error changeset" do
      product = product_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_product(product, @invalid_attrs)
      assert product == Inventory.get_product!(product.id)
    end

    test "delete_product/1 deletes the product" do
      product = product_fixture()
      assert {:ok, %Product{}} = Inventory.delete_product(product)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_product!(product.id) end
    end

    test "change_product/1 returns a product changeset" do
      product = product_fixture()
      assert %Ecto.Changeset{} = Inventory.change_product(product)
    end
  end
end
