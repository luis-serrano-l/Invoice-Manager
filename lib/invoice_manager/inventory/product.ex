defmodule InvoiceManager.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Inventory.Company

  schema "products" do
    field :name, :string
    field :price, :decimal
    field :stock, :integer
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock])
    |> validate_required([:name, :price, :stock])
  end
end
