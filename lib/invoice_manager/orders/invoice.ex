defmodule InvoiceManager.Orders.Invoice do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Business.Company
  alias InvoiceManager.Orders.Item

  schema "invoices" do
    field :billing_date, :date
    field :discount, :float, default: 0.00
    field :extra_info, :string
    field :invoice_number, :integer
    field :operation_date, :date
    field :tax_rate, :float, default: 0.00
    field :total, :float, default: 0.00
    field :sent, :boolean, default: false
    belongs_to :company, Company
    belongs_to :customer, Company
    has_many :items, Item, on_replace: :delete

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
      :extra_info,
      :sent
    ])
  end

  def changeset_to_send(invoice, attrs) do
    invoice
    |> cast(attrs, [
      :invoice_number,
      :billing_date,
      :operation_date,
      :tax_rate,
      :discount,
      :total,
      :extra_info,
      :sent
    ])
    |> validate_required([
      :invoice_number,
      :billing_date,
      :tax_rate,
      :total
    ])
    |> validate_number(:tax_rate, greater_than: -0.01)
    |> validate_number(:discount, greater_than: -0.01)
    |> validate_number(:total, greater_than: 0)
  end
end
