defmodule InvoiceManager.Repo.Migrations.CreateUsersAndCompanies do
  use Ecto.Migration

  def change do
    create table(:users_and_companies) do
      add :admin, :boolean, default: false, null: false
      add :company_id, references(:companies, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:users_and_companies, [:company_id])
    create index(:users_and_companies, [:user_id])
  end
end
