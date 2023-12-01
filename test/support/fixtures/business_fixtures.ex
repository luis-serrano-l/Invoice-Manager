defmodule InvoiceManager.BusinessFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceManager.Business` context.
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
      |> InvoiceManager.Business.create_company()

    company
  end
end
