defmodule InvoiceManagerWeb.ViewInvoiceLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Orders
  use InvoiceManagerWeb, :live_view

  def mount(
        %{"company_name" => company_name, "role" => _role, "invoice_id" => invoice_id},
        _session,
        socket
      ) do
    invoice_id = String.to_integer(invoice_id)
    invoice = Orders.get_invoice(company_name, invoice_id)
    items = Orders.list_items(company_name, invoice_id)
    value = calculate_value(items)
    tax = (value * (Decimal.to_float(invoice.tax_rate) / 100)) |> Float.round(2)

    socket =
      assign(socket,
        invoice: invoice,
        items: items,
        value: value,
        tax: tax
      )

    {:ok, socket}
  end

  defp get_company_name(company_id), do: Business.get_company_name(company_id)

  defp calculate_value(items) do
    items
    |> Enum.reduce(0, fn item, acc ->
      item.quantity * Decimal.to_float(item.fixed_price) +
        acc
    end)
    |> Float.round(2)
  end

  defp calculate_item_value(quantity, price) do
    (quantity *
       Decimal.to_float(price))
    |> Float.round(2)
  end

  defp to_eur(number) when is_float(number) do
    number = Float.to_string(number)

    if Regex.match?(~r/^\d+\.\d$/, number) do
      number <> "0 €"
    else
      number <> " €"
    end
  end

  defp to_eur(number) do
    number = Decimal.to_string(number)

    cond do
      Regex.match?(~r/^\d+\.\d$/, number) ->
        number <> "0 €"

      Regex.match?(~r/^\d+$/, number) ->
        number <> ".00 €"

      true ->
        number <> " €"
    end
  end
end
