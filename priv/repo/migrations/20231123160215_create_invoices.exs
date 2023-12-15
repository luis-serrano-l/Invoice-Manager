defmodule InvoiceManager.Repo.Migrations.CreateInvoices do
  use Ecto.Migration

  def change do
    create table(:invoices) do
      add :invoice_number, :integer
      add :billing_date, :date
      add :operation_date, :date
      add :tax_rate, :decimal
      add :discount, :decimal
      add :total, :decimal
      add :extra_info, :string
      add :sent, :boolean
      add :company_id, references(:companies, on_delete: :nothing)
      add :customer_id, references(:companies, on_delete: :nothing)

      timestamps()
    end

    create index(:invoices, [:company_id])
    create index(:invoices, [:customer_id])
  end
end
