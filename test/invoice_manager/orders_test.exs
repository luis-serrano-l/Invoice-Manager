defmodule InvoiceManager.OrdersTest do
  use InvoiceManager.DataCase

  alias InvoiceManager.Orders

  describe "invoices" do
    alias InvoiceManager.Orders.Invoice

    import InvoiceManager.OrdersFixtures

    @invalid_attrs %{
      billing_date: nil,
      discount: nil,
      extra_info: nil,
      operation_date: nil,
      tax_rate: nil,
      total: nil
    }

    test "list_invoices/0 returns all invoices" do
      invoice = invoice_fixture()
      assert Orders.list_invoices() == [invoice]
    end

    test "get_invoice!/1 returns the invoice with given id" do
      invoice = invoice_fixture()
      assert Orders.get_invoice!(invoice.id) == invoice
    end

    test "create_invoice/1 with valid data creates a invoice" do
      valid_attrs = %{
        billing_date: ~D[2023-11-22],
        discount: "120.5",
        extra_info: "some extra_info",
        operation_date: ~D[2023-11-22],
        tax_rate: "120.5",
        total: "120.5"
      }

      assert {:ok, %Invoice{} = invoice} = Orders.create_invoice(valid_attrs)
      assert invoice.billing_date == ~D[2023-11-22]
      assert invoice.discount == 120.5
      assert invoice.extra_info == "some extra_info"
      assert invoice.operation_date == ~D[2023-11-22]
      assert invoice.tax_rate == 120.5
      assert invoice.total == 120.5
    end

    test "create_invoice/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_invoice(@invalid_attrs)
    end

    test "update_invoice/2 with valid data updates the invoice" do
      invoice = invoice_fixture()

      update_attrs = %{
        billing_date: ~D[2023-11-23],
        discount: "456.7",
        extra_info: "some updated extra_info",
        operation_date: ~D[2023-11-23],
        tax_rate: "456.7",
        total: "456.7"
      }

      assert {:ok, %Invoice{} = invoice} = Orders.update_invoice(invoice, update_attrs)
      assert invoice.billing_date == ~D[2023-11-23]
      assert invoice.discount == 456.7
      assert invoice.extra_info == "some updated extra_info"
      assert invoice.operation_date == ~D[2023-11-23]
      assert invoice.tax_rate == 456.7
      assert invoice.total == 456.7
    end

    test "update_invoice/2 with invalid data returns error changeset" do
      invoice = invoice_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_invoice(invoice, @invalid_attrs)
      assert invoice == Orders.get_invoice!(invoice.id)
    end

    test "delete_invoice/1 deletes the invoice" do
      invoice = invoice_fixture()
      assert {:ok, %Invoice{}} = Orders.delete_invoice(invoice)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_invoice!(invoice.id) end
    end

    test "change_invoice/1 returns a invoice changeset" do
      invoice = invoice_fixture()
      assert %Ecto.Changeset{} = Orders.change_invoice(invoice)
    end
  end

  describe "items" do
    alias InvoiceManager.Orders.Item

    import InvoiceManager.OrdersFixtures

    @invalid_attrs %{quantity: nil}

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Orders.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Orders.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      valid_attrs = %{quantity: 42}

      assert {:ok, %Item{} = item} = Orders.create_item(valid_attrs)
      assert item.quantity == 42
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orders.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      update_attrs = %{quantity: 43}

      assert {:ok, %Item{} = item} = Orders.update_item(item, update_attrs)
      assert item.quantity == 43
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Orders.update_item(item, @invalid_attrs)
      assert item == Orders.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Orders.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Orders.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Orders.change_item(item)
    end
  end
end
