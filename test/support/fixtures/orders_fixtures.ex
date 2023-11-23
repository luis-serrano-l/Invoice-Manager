defmodule InvoiceManager.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceManager.Orders` context.
  """

  @doc """
  Generate a invoice.
  """
  def invoice_fixture(attrs \\ %{}) do
    {:ok, invoice} =
      attrs
      |> Enum.into(%{
        billing_date: ~D[2023-11-22],
        discount: "120.5",
        extra_info: "some extra_info",
        invoice_number: 42,
        operation_date: ~D[2023-11-22],
        tax_rate: "120.5",
        total: "120.5"
      })
      |> InvoiceManager.Orders.create_invoice()

    invoice
  end

  @doc """
  Generate a item.
  """
  def item_fixture(attrs \\ %{}) do
    {:ok, item} =
      attrs
      |> Enum.into(%{
        quantity: 42
      })
      |> InvoiceManager.Orders.create_item()

    item
  end
end
