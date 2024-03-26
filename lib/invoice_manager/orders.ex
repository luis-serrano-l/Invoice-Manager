defmodule InvoiceManager.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false

  alias InvoiceManager.Business.Company
  alias InvoiceManager.Inventory
  alias InvoiceManager.Orders.Invoice
  alias InvoiceManager.Orders.Item
  alias InvoiceManager.Repo

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  @spec list_invoices(integer(), integer(), integer(), String.t()) :: list(struct())
  def list_invoices(company_id, size, offset, "incoming") do
    invoices =
      from i in Invoice,
        where: i.customer_id == ^company_id,
        where: i.sent == true,
        select: i,
        order_by: [desc: i.updated_at],
        offset: ^offset,
        limit: ^size

    Repo.all(invoices)
  end

  def list_invoices(company_id, size, offset, "outgoing") do
    invoices =
      from i in Invoice,
        where: i.company_id == ^company_id,
        where: i.sent == true,
        order_by: i.updated_at,
        select: i,
        order_by: [desc: i.updated_at],
        offset: ^offset,
        limit: ^size

    Repo.all(invoices)
  end

  def list_unsent_invoices(company_id) do
    invoices =
      from i in Invoice,
        where: i.company_id == ^company_id,
        where: i.sent == false,
        select: i

    Repo.all(invoices)
  end

  def count_invoices(company_id, "incoming") do
    invoices =
      from i in Invoice,
        where: i.customer_id == ^company_id,
        where: i.sent == true,
        select: i

    Repo.aggregate(invoices, :count)
  end

  def count_invoices(company_id, "outgoing") do
    invoices =
      from i in Invoice,
        where: i.company_id == ^company_id,
        where: i.sent == true,
        select: i

    Repo.aggregate(invoices, :count)
  end

  @doc """
  Gets a single invoice.

  Raises `Ecto.NoResultsError` if the Invoice does not exist.

  ## Examples

      iex> get_invoice!(123)
      %Invoice{}

      iex> get_invoice!(456)
      ** (Ecto.NoResultsError)

  """
  def get_invoice!(id), do: Repo.get!(Invoice, id)

  @doc """
  Creates a invoice.

  ## Examples

      iex> create_invoice(%{field: value})
      {:ok, %Invoice{}}

      iex> create_invoice(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_invoice(company_name, customer_name) do
    company = Repo.get_by(Company, name: company_name)
    customer = Repo.get_by(Company, name: customer_name)

    if customer do
      Ecto.build_assoc(company, :invoices, customer_id: customer.id)
      |> Repo.insert()
    else
      {:error, "Company does not exist"}
    end
  end

  @doc """
  Updates a invoice.

  ## Examples

      iex> update_invoice(invoice, %{field: new_value})
      {:ok, %Invoice{}}

      iex> update_invoice(invoice, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_invoice(%Invoice{} = invoice, attrs) do
    invoice
    |> Invoice.changeset_to_send(attrs)
    |> Repo.update()
  end

  @spec update_full_invoice(integer(), [struct()], map()) :: tuple()
  def update_full_invoice(id, items, attrs) do
    params = %{items: item_params(items)}

    get_invoice!(id)
    |> Repo.preload(:items)
    |> Invoice.full_changeset(attrs, params)
    |> Repo.update()
  end

  @spec item_params([struct()]) :: [map()]
  defp item_params(items) do
    Enum.map(items, fn item ->
      if Map.get(item, :id),
        do: %{id: item.id, name: item.name, price: item.price, quantity: item.quantity},
        else: %{
          product_id: item.product_id,
          name: item.name,
          price: item.price,
          quantity: item.quantity
        }
    end)
  end

  @doc """
  Deletes a invoice.

  ## Examples

      iex> delete_invoice(invoice)
      {:ok, %Invoice{}}

      iex> delete_invoice(invoice)
      {:error, %Ecto.Changeset{}}

  """
  def delete_invoice(%Invoice{} = invoice) do
    from(item in "items", where: item.invoice_id == ^invoice.id)
    |> Repo.delete_all()

    Repo.delete(invoice)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking invoice changes.

  ## Examples

      iex> change_invoice(invoice)
      %Ecto.Changeset{data: %Invoice{}}

  """
  def change_invoice(%Invoice{} = invoice, attrs \\ %{}) do
    Invoice.changeset(invoice, attrs)
  end

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(invoice_id) do
    items =
      from i in Item,
        where: i.invoice_id == ^invoice_id,
        select: i,
        order_by: [desc: i.inserted_at]

    Repo.all(items)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_item(integer(), integer(), map()) :: tuple()
  def create_item(product_id, invoice_id, attrs \\ %{}) do
    invoice = get_invoice!(invoice_id)
    item = Ecto.build_assoc(invoice, :items, product_id: product_id)

    item
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update!()
  end

  @spec update_item_price_and_name([struct()]) :: [map()]
  def update_item_price_and_name(items) do
    Enum.map(items, fn item ->
      product = Inventory.get_product!(item.product_id)

      update_item(item, %{
        "name" => product.name,
        "price" => product.price,
        "quantity" => item.quantity
      })
    end)
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{data: %Item{}}

  """
  def change_item(%Item{} = item, attrs \\ %{}) do
    Item.changeset(item, attrs)
  end
end
