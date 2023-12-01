defmodule InvoiceManager.BusinessTest do
  use InvoiceManager.DataCase

  alias InvoiceManager.Business

  describe "companies" do
    alias InvoiceManager.Business.Company

    import InvoiceManager.BusinessFixtures

    @invalid_attrs %{address: nil, contact_email: nil, contact_phone: nil, fiscal_number: nil, name: nil}

    test "list_companies/0 returns all companies" do
      company = company_fixture()
      assert Business.list_companies() == [company]
    end

    test "get_company!/1 returns the company with given id" do
      company = company_fixture()
      assert Business.get_company!(company.id) == company
    end

    test "create_company/1 with valid data creates a company" do
      valid_attrs = %{address: "some address", contact_email: "some contact_email", contact_phone: "some contact_phone", fiscal_number: "some fiscal_number", name: "some name"}

      assert {:ok, %Company{} = company} = Business.create_company(valid_attrs)
      assert company.address == "some address"
      assert company.contact_email == "some contact_email"
      assert company.contact_phone == "some contact_phone"
      assert company.fiscal_number == "some fiscal_number"
      assert company.name == "some name"
    end

    test "create_company/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Business.create_company(@invalid_attrs)
    end

    test "update_company/2 with valid data updates the company" do
      company = company_fixture()
      update_attrs = %{address: "some updated address", contact_email: "some updated contact_email", contact_phone: "some updated contact_phone", fiscal_number: "some updated fiscal_number", name: "some updated name"}

      assert {:ok, %Company{} = company} = Business.update_company(company, update_attrs)
      assert company.address == "some updated address"
      assert company.contact_email == "some updated contact_email"
      assert company.contact_phone == "some updated contact_phone"
      assert company.fiscal_number == "some updated fiscal_number"
      assert company.name == "some updated name"
    end

    test "update_company/2 with invalid data returns error changeset" do
      company = company_fixture()
      assert {:error, %Ecto.Changeset{}} = Business.update_company(company, @invalid_attrs)
      assert company == Business.get_company!(company.id)
    end

    test "delete_company/1 deletes the company" do
      company = company_fixture()
      assert {:ok, %Company{}} = Business.delete_company(company)
      assert_raise Ecto.NoResultsError, fn -> Business.get_company!(company.id) end
    end

    test "change_company/1 returns a company changeset" do
      company = company_fixture()
      assert %Ecto.Changeset{} = Business.change_company(company)
    end
  end
end
