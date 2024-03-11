defmodule InvoiceManager.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :float
      add :stock, :integer
      add :sku, :integer
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:products, [:sku])
    create unique_index(:products, [:name, :company_id], name: :products_name_company_id_index)
  end
end
