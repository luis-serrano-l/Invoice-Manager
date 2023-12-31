defmodule InvoiceManager.Orders.Invoice do
  alias InvoiceManager.Business.Company
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Orders.Item

  schema "invoices" do
    field :billing_date, :date
    field :discount, :decimal, default: 0.0
    field :extra_info, :string
    field :invoice_number, :integer
    field :operation_date, :date
    field :tax_rate, :decimal, default: 0.0
    field :total, :decimal, default: 0
    field :sent, :boolean, default: false
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
      :sent
    ])
    |> validate_number(:tax_rate, greater_than: -0.01)
    |> validate_number(:discount, greater_than: -0.01)
    |> validate_number(:total, greater_than: 0)
  end

  """
    defp validate_lower_than(changeset, field1, field2) do
      if get_field(changeset, field1) > get_field(changeset, field2) do
        changeset
        |> add_error(field1, "must be lower than # {field2}")
      else
        changeset
      end
    end
  """

  """
  def valid_date?(%Invoice{billing_date: billing_date}) do
    billing_date > Date.utc_today()
  end

  def validate_date(changeset, date) do
    if valid_date?(changeset.data, date) do
      changeset
    else
      add_error(changeset, :billing_date, "is not valid")
    end
  end
  """
end
