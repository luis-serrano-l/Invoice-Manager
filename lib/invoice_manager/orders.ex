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
  def list_invoices(company_name, "personal") do
    invoices =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.customer_id == company.id,
        where: invoice.sent == true,
        select: invoice

    Repo.all(invoices)
  end

  def list_invoices(company_name, "customers") do
    invoices =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.company_id == company.id,
        where: invoice.sent == true,
        select: invoice

    Repo.all(invoices)
  end

  def list_unsent_invoices(company_name) do
    invoice =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.sent == false,
        select: invoice

    Repo.all(invoice)
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

  def get_invoice(company_name, invoice_id) do
    invoice =
      from company in Company,
        where: company.name == ^company_name,
        join: invoice in assoc(company, :invoices),
        where: invoice.id == ^invoice_id,
        select: invoice

    Repo.one(invoice)
  end

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

  def temporary_update_invoice(%Invoice{} = invoice, attrs) do
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


  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def fix_items_price_and_name(items, products) do
    items
    |> IO.inspect(label: "ITEMS")
    |> Enum.map(fn item ->
      item
      |> update_item(get_product_name_and_price(products, item.product_id))
    end)
  end

  defp get_product_name_and_price(products, product_id) do
    product = Enum.find(products, &(&1.id == product_id)) |> IO.inspect(label: "PRODUCT")
    %{name: name, price: price} = product
    %{"fixed_name" => name, "fixed_price" => price}
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
