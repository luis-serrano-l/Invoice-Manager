defmodule InvoiceManager.Business.Company do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Accounts.User
  alias InvoiceManager.Inventory.Product
  alias InvoiceManager.Orders.Invoice

  schema "companies" do
    field :address, :string
    field :contact_email, :string
    field :contact_phone, :string
    field :fiscal_number, :string
    field :name, :string
    has_many :users, User
    has_many :products, Product
    has_many :invoices, Invoice
    has_many :items, through: [:invoices, :items]

    timestamps()
  end

  @doc false
  def changeset(company, attrs) do
    company
    |> cast(attrs, [:name, :address, :contact_email, :contact_phone, :fiscal_number])
    |> validate_required([:name, :address, :contact_email, :fiscal_number])
    |> validate_format(:contact_email, ~r/^[a-zA-Z\d_@\.]+$/, message: "invalid characters")
    |> validate_format(
      :contact_email,
      ~r/.+@(hotmail|gmail|outlook|doofinder|yahoo|google)\.(es|com)$/,
      message: "invalid extension"
    )
    |> validate_length(:contact_email, max: 160)
    |> unique_constraint(:name)
    |> unique_constraint(:fiscal_number)
  end
end
