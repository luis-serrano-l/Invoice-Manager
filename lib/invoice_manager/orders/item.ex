defmodule InvoiceManager.Orders.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Business.Company
  alias InvoiceManager.Orders.Invoice

  schema "items" do
    field :quantity, :integer
    field :product_id, :id
    belongs_to :invoice, Invoice
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:quantity])
    |> validate_required([:quantity])
  end
end
