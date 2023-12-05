defmodule InvoiceManager.Orders.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Inventory.Product
  alias InvoiceManager.Business.Company
  alias InvoiceManager.Orders.Invoice

  schema "items" do
    field :quantity, :integer, default: 1
    belongs_to :product, Product
    belongs_to :invoice, Invoice
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:quantity])
    |> validate_required([:quantity])
    |> unique_constraint(:invoice_id,
      name: :invoice_id_product_id_index
    )
  end
end
