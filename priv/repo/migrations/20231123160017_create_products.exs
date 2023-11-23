defmodule InvoiceManager.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :price, :decimal
      add :stock, :integer
      add :company_id, references(:companies, on_delete: :nothing)

      timestamps()
    end

    create index(:products, [:company_id])
  end
end
