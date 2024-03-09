defmodule InvoiceManager.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Business.Company
  alias InvoiceManager.Orders.Item

  schema "products" do
    field :name, :string
    field :price, :float
    field :stock, :integer, default: 0
    field :sku, :integer
    has_many :item, Item
    belongs_to :company, Company

    timestamps()
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :price, :stock, :sku, :company_id])
    |> validate_required([:name, :price, :stock, :sku, :company_id])
    |> validate_format(:name, ~r/^[A-Za-z0-9]/,
      message: "Must start with an alphanumberic character"
    )
    |> validate_number(:price, greater_than: 0.0)
    |> validate_number(:stock, greater_than: -1)
    |> unique_constraint(:sku)
    |> unique_constraint(:name, name: :products_name_company_id_index)
  end
end

# |> unique_constraint([:name, :company_id])
#  name: :company_product_index,
#  message: "Product name must be unique within a company"
# )
