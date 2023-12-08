defmodule InvoiceManager.Orders do
  @moduledoc """
  The Orders context.
  """

  import Ecto.Query, warn: false
  alias InvoiceManager.Business.Company
  alias InvoiceManager.Repo

  alias InvoiceManager.Orders.Invoice

  @doc """
  Returns the list of invoices.

  ## Examples

      iex> list_invoices()
      [%Invoice{}, ...]

  """
  def list_invoices do
    Repo.all(Invoice)
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
      |> IO.inspect(label: "INSERTED INVOICE NOW")
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
    |> Invoice.changeset(attrs)
    |> Repo.update()
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

  alias InvoiceManager.Orders.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items(company_name, invoice_id) do
    items =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.id == ^invoice_id,
        join: item in assoc(invoice, :items),
        select: item,
        order_by: item.inserted_at

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

  def get_item(company_name, invoice_id, item_id) do
    item =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.id == ^invoice_id,
        join: item in assoc(invoice, :items),
        where: item.id == ^item_id,
        select: item

    Repo.one(item)
  end

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(product_id, company_name, invoice_id) do
    invoice =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.id == ^invoice_id,
        select: invoice

    invoice = Repo.one(invoice)
    item = Ecto.build_assoc(invoice, :items, product_id: product_id)

    item
    |> Item.changeset(%{})
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

  def update_item(item, :add) do
    item
    |> Item.changeset(%{"quantity" => item.quantity + 1})
    |> Repo.update()
  end

  def update_item(item, :subtract) do
    item
    |> Item.changeset(%{"quantity" => item.quantity - 1})
    |> Repo.update()
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
