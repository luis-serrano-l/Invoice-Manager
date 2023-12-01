defmodule InvoiceManager.Orders.Invoice do
  alias InvoiceManager.Business.Company
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Orders.Item

  schema "invoices" do
    field :billing_date, :date
    field :discount, :decimal
    field :extra_info, :string
    field :invoice_number, :integer
    field :operation_date, :date
    field :tax_rate, :decimal
    field :total, :decimal
    belongs_to :company, Company
    belongs_to :customer, Company
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :invoice_number,
      :billing_date,
      :operation_date,
      :tax_rate,
      :discount,
      :total,
      :extra_info
    ])
    |> validate_required([
      :invoice_number,
      :billing_date,
      :operation_date,
      :tax_rate,
      :discount,
      :total
    ])
    |> validate_number(:total, greater_than: 0)
  end
end
