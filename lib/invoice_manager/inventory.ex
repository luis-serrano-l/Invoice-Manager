defmodule InvoiceManager.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias InvoiceManager.Business.Company
  alias InvoiceManager.Repo
  alias InvoiceManager.Inventory.Product

  def list_products(company_name) do
    products =
      from company in Company,
        where: company.name == ^company_name,
        join: product in assoc(company, :products),
        select: product,
        order_by: product.inserted_at

    Repo.all(products)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  def get_product(company_name, id) do
    product =
      from company in Company,
        where: company.name == ^company_name,
        join: product in assoc(company, :products),
        where: product.id == ^id,
        select: product

    Repo.one(product)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(company_name, attrs) do
    company = Repo.get_by(Company, name: company_name)
    product_params = Map.put(attrs, "company_id", company.id)

    %Product{}
    |> Product.changeset(product_params)
    |> Repo.insert()
    |> IO.inspect(label: "CREATED PRODUCT")
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_product(product, :subtract) do
    product
    |> Product.changeset(%{"stock" => product.stock - 1})
    |> Repo.update()
    |> IO.inspect(label: "CHANGED PRODUCT")
  end

  def update_product(product, :add) do
    product
    |> Product.changeset(%{"stock" => product.stock + 1})
    |> Repo.update()
  end

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Product{} = product, attrs \\ %{}) do
    Product.changeset(product, attrs)
  end
end
