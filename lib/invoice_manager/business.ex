defmodule InvoiceManager.Business do
  @moduledoc """
  The Business context.
  """

  import Ecto.Query, warn: false
  alias InvoiceManager.Accounts.User
  alias InvoiceManager.Repo

  alias InvoiceManager.Business.Company

  @doc """
  Returns the list of companies.

  ## Examples

      iex> list_companies()
      [%Company{}, ...]

  """
  def list_companies do
    Repo.all(Company)
  end

  def list_company_ids_by_user_id(user_id) do
    company_ids =
      from user in User,
        where: user.id == ^user_id,
        join: user_and_company in assoc(user, :users_and_companies),
        select: user_and_company.company_id

    Repo.all(company_ids)
  end

  def list_company_names_by_ids([]), do: nil

  def list_company_names_by_ids(company_ids) do
    company_names =
      from company in Company,
        where: company.id in ^company_ids,
        select: company.name

    Repo.all(company_names)
  end

  @doc """
  Gets a single company.

  Raises `Ecto.NoResultsError` if the Company does not exist.

  ## Examples

      iex> get_company!(123)
      %Company{}

      iex> get_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_company!(id), do: Repo.get!(Company, id)

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a company.

  ## Examples

      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_company(%Company{} = company, attrs) do
    company
    |> Company.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a company.

  ## Examples

      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    Repo.delete(company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking company changes.

  ## Examples

      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
    Company.changeset(company, attrs)
  end

  alias InvoiceManager.Business.UserAndCompany

  @doc """
  Returns the list of users_and_companies.

  ## Examples

      iex> list_users_and_companies()
      [%UserAndCompany{}, ...]

  """
  def list_users_and_companies do
    Repo.all(UserAndCompany)
  end

  @doc """
  Gets a single user_and_company.

  Raises `Ecto.NoResultsError` if the User and company does not exist.

  ## Examples

      iex> get_user_and_company!(123)
      %UserAndCompany{}

      iex> get_user_and_company!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_and_company!(id), do: Repo.get!(UserAndCompany, id)

  @doc """
  Creates a user_and_company.

  ## Examples

      iex> create_user_and_company(%{field: value})
      {:ok, %UserAndCompany{}}

      iex> create_user_and_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_and_company(attrs \\ %{}) do
    %UserAndCompany{}
    |> UserAndCompany.changeset(attrs)
    |> Repo.insert()
  end

  def create_admin_and_company(user_id, company) do
    new_user_and_company =
      Ecto.build_assoc(company, :users_and_companies, admin: true, user_id: user_id)

    Repo.insert(new_user_and_company)
  end

  @doc """
  Updates a user_and_company.

  ## Examples

      iex> update_user_and_company(user_and_company, %{field: new_value})
      {:ok, %UserAndCompany{}}

      iex> update_user_and_company(user_and_company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_and_company(%UserAndCompany{} = user_and_company, attrs) do
    user_and_company
    |> UserAndCompany.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_and_company.

  ## Examples

      iex> delete_user_and_company(user_and_company)
      {:ok, %UserAndCompany{}}

      iex> delete_user_and_company(user_and_company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_and_company(%UserAndCompany{} = user_and_company) do
    Repo.delete(user_and_company)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_and_company changes.

  ## Examples

      iex> change_user_and_company(user_and_company)
      %Ecto.Changeset{data: %UserAndCompany{}}

  """
  def change_user_and_company(%UserAndCompany{} = user_and_company, attrs \\ %{}) do
    UserAndCompany.changeset(user_and_company, attrs)
  end
end
