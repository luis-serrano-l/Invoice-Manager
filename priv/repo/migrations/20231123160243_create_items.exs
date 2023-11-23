defmodule InvoiceManager.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :quantity, :integer
      add :product_id, references(:products, on_delete: :nothing)
      add :invoice_id, references(:invoices, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:product_id])
    create index(:items, [:invoice_id])
  end
end
