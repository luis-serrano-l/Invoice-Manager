defmodule InvoiceManager.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceManager.Inventory` context.
  """

  @doc """
  Generate a company.
  """
  def company_fixture(attrs \\ %{}) do
    {:ok, company} =
      attrs
      |> Enum.into(%{
        address: "some address",
        contact_email: "some contact_email",
        contact_phone: "some contact_phone",
        fiscal_number: "some fiscal_number",
        name: "some name"
      })
      |> InvoiceManager.Inventory.create_company()

    company
  end

  @doc """
  Generate a product.
  """
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "some name",
        price: "120.5",
        stock: 42
      })
      |> InvoiceManager.Inventory.create_product()

    product
  end
end
