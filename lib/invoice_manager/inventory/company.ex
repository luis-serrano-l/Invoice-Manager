defmodule InvoiceManager.Inventory.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Accounts.UserAndCompany
  alias InvoiceManager.Orders.Invoice
  alias InvoiceManager.Inventory.Product

  schema "companies" do
    field :address, :string
    field :contact_email, :string
    field :contact_phone, :string
    field :fiscal_number, :string
    field :name, :string
    has_many :users_and_companies, UserAndCompany
    has_many :products, Product
    has_many :invoices, Invoice
    has_many :items, through: [:invoices, :items]

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :address, :contact_email, :contact_phone, :fiscal_number])
    |> validate_required([:name, :address, :contact_email, :contact_phone, :fiscal_number])
  end
end
