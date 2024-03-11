defmodule InvoiceManager.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias InvoiceManager.Business
  alias InvoiceManager.Inventory.Product
  alias InvoiceManager.Repo

  def list_products(company_id, size, offset) do
    products =
      from p in Product,
        where: p.company_id == ^company_id,
        select: p,
        order_by: [desc: p.updated_at],
        offset: ^offset,
        limit: ^size

    Repo.all(products)
  end

  def search_products(company_id, product_string) do
    products =
      from p in Product,
        where: p.company_id == ^company_id,
        select: p,
        where: ilike(p.name, ^"#{product_string}%")

    Repo.all(products)
  end

  def count_products(company_id) do
    products =
      from p in Product,
        where: p.company_id == ^company_id,
        select: p

    Repo.aggregate(products, :count)
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

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(company_id, attrs) do
    product_params = Map.put(attrs, "company_id", company_id)

    %Product{}
    |> Product.changeset(product_params)
    |> Repo.insert()
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
  end

  def update_each_product_stock(company_id, items) do
    ids_for_update = Enum.map(items, & &1.product_id)

    ids_not_to_change_stock =
      from p in Product,
        where: p.company_id == ^company_id,
        where: p.id not in ^ids_for_update,
        select: %{id: p.id}

    ids_not_to_change_stock = Repo.all(ids_not_to_change_stock)

    changed_stock =
      Enum.map(items, fn item ->
        product = get_product!(item.product_id)
        %{id: product.id, stock: product.stock - item.quantity}
      end)

    Business.get_company!(company_id)
    |> Repo.preload(:products)
    |> cast(%{products: ids_not_to_change_stock ++ changed_stock}, [])
    |> cast_assoc(:products)
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
