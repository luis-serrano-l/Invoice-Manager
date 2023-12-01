defmodule InvoiceManager.Repo.Migrations.CreateCompanies do
  use Ecto.Migration

  def change do
    create table(:companies) do
      add :name, :string
      add :address, :string
      add :contact_email, :string
      add :contact_phone, :string
      add :fiscal_number, :string

      timestamps()
    end

    create unique_index(:companies, [:name])
  end
end
