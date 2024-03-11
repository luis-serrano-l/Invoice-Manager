defmodule InvoiceManager.Utils do
  alias InvoiceManager.Business
  alias InvoiceManager.Inventory
  alias InvoiceManager.Orders

  def to_euro(0), do: "0.00 €"
  def to_euro(number), do: :erlang.float_to_binary(number, decimals: 2) <> " €"

  def change_map(old_map, new_map) do
    Map.merge(old_map, new_map, fn _k, _v1, v2 -> v2 end)
  end

  def new_paginate(company_id, size, role \\ nil) do
    get_pages(company_id, size, role)
    |> ceil()
    |> max(1)
    |> paginate(0, 1, 0)
  end

  defp get_pages(company_id, size, nil), do: Inventory.count_products(company_id) / size
  defp get_pages(company_id, size, role), do: Orders.count_invoices(company_id, role) / size

  def paginate(pages, offset, page_num, move) do
    %{pages: pages, offset: offset, page_num: page_num + move}
  end

  def change_page(company_id, pagination, move, size, role \\ nil) do
    offset = pagination.offset + size * move

    elements =
      if !role,
        do: [products: Inventory.list_products(company_id, size, offset)],
        else: [invoices: Orders.list_invoices(company_id, size, offset, role)]

    elements ++ [pagination: paginate(pagination.pages, offset, pagination.page_num, move)]
  end

  def get_costs(items, tax_rate, discount) do
    value = calculate_value(items)

    taxes =
      (value * tax_rate / 100)
      |> Float.round(2)

    total =
      (value + taxes - discount)
      |> Float.round(2)

    %{value: value, taxes: taxes, total: total, tax_rate: tax_rate, discount: discount}
  end

  defp calculate_value([]), do: 0

  defp calculate_value(items) do
    items
    |> Enum.reduce(0, fn item, acc ->
      item.quantity *
        item.price +
        acc
    end)
    |> Float.round(2)
  end

  def get_company_name(id), do: Business.get_company_name(id)
end
