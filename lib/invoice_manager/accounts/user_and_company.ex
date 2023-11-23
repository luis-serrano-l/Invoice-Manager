defmodule InvoiceManager.Accounts.UserAndCompany do
  use Ecto.Schema
  import Ecto.Changeset

  alias InvoiceManager.Accounts.User
  alias InvoiceManager.Inventory.Company

  schema "users_and_companies" do
    field :admin, :boolean, default: false
    belongs_to :company, Company
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_and_company, attrs) do
    user_and_company
    |> cast(attrs, [:admin])
    |> validate_required([:admin])
  end
end
