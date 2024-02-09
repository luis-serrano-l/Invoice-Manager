defmodule InvoiceManagerWeb.EditorLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Accounts
  alias InvoiceManager.Inventory
  use InvoiceManagerWeb, :live_view
  alias InvoiceManager.Orders.Invoice
  alias InvoiceManager.Orders

  def mount(
        %{
          "company_name" => _company_name,
          "customer_name" => customer_name,
          "invoice_id" => invoice_id
        },
        session,
        socket
      ) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company = Business.get_company!(user.company_id)
    company_name = company.name
    invoice_id = String.to_integer(invoice_id)
    invoice = Orders.get_invoice!(invoice_id)
    invoice_changeset = Orders.change_invoice(invoice)
    products = Inventory.list_products(company_name)
    items = Orders.list_items(company_name, invoice_id)
    tax_rate = Decimal.to_float(invoice.tax_rate)
    discount = Decimal.to_float(invoice.discount)
    value = calculate_value(items, products)
    taxes = calculate_tax(value, tax_rate)
    total = calculate_total(value, taxes, discount)
    Process.send_after(self(), :clear_flash, 1000)

    socket =
      assign(socket,
        company_name: company_name,
        customer_name: customer_name,
        operation_date: Date.utc_today(),
        invoice_id: invoice_id,
        user_is_admin: user.is_admin,
        form: to_form(invoice_changeset),
        products: products,
        items: items,
        new_item: true,
        tax_rate: tax_rate,
        taxes: taxes,
        discount: discount,
        value: value,
        total: total,
        product_id_to_change: nil,
        is_saved: false
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"invoice" => params}, socket) do
    %{"discount" => discount} = params
    %{"tax_rate" => tax_rate} = params
    discount = get_number(discount)
    tax_rate = get_number(tax_rate)

    params =
      params
      |> Map.update!("discount", fn _ -> discount end)
      |> Map.update!("tax_rate", fn _ -> tax_rate end)

    form =
      %Invoice{}
      |> Orders.change_invoice(params)
      |> Map.put(:action, :insert)
      |> to_form()

    items = socket.assigns.items

    products = Inventory.list_products(socket.assigns.company_name)

    value = calculate_value(items, products)
    taxes = calculate_tax(value, tax_rate)
    total = calculate_total(value, taxes, discount)

    {:noreply,
     assign(socket, form: form)
     |> assign(discount: discount)
     |> assign(value: value)
     |> assign(taxes: taxes)
     |> assign(tax_rate: tax_rate)
     |> assign(total: total)
     |> assign(is_saved: false)}
  end

  def handle_event("send", _, socket) do
    Process.send_after(self(), :clear_flash, 1200)

    if !socket.assigns.is_saved do
      {:noreply,
       socket
       |> put_flash(:error, "Cannot send before saving")}
    else
      invoice = Orders.get_invoice(socket.assigns.company_name, socket.assigns.invoice_id)
      {:ok, invoice} = Orders.update_invoice(invoice, %{"sent" => true})

      {:noreply,
       socket
       |> assign(invoice: invoice)
       |> put_flash(:info, "invoice sent")
       |> redirect(to: ~p"/invoice_manager/#{socket.assigns.company_name}")}
    end
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    cond do
      socket.assigns.total <= 0 ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Total should be higher than 0")
         |> assign(is_saved: false)}

      is_before?(invoice_params) ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Billing date cannot be before today")
         |> assign(is_saved: false)}

      true ->
        Orders.update_items_and_products(
          socket.assigns.company_name,
          socket.assigns.invoice_id,
          socket.assigns.items
        )

        attrs =
          invoice_params
          |> Map.put("operation_date", Date.utc_today())
          |> Map.put("total", socket.assigns.total)
          |> Map.put("invoice_number", socket.assigns.invoice_id)

        invoice = Orders.get_invoice(socket.assigns.company_name, socket.assigns.invoice_id)

        update_invoice(invoice, attrs, socket)
    end
  end

  def handle_event("new_item", _, socket) do
    {:noreply,
     socket
     |> assign(new_item: true)}
  end

  def handle_event("hide_inventory", _, socket) do
    {:noreply,
     socket
     |> assign(new_item: false)}
  end

  def handle_event("select_item", %{"product_id" => product_id} = _params, socket) do
    product_id = String.to_integer(product_id)

    product = Inventory.get_product!(product_id)

    items = socket.assigns.items

    Process.send_after(self(), :clear_flash, 1200)

    cond do
      !product or product.stock == 0 ->
        {:noreply,
         socket
         |> put_flash(:error, "Out of stock")}

      product_id in Enum.map(items, & &1.product_id) ->
        items =
          Enum.map(items, fn item ->
            if item.product_id == product_id,
              do: Map.update!(item, :quantity, &(&1 + 1)),
              else: item
          end)

        value = calculate_value(socket.assigns.items, socket.assigns.products)
        taxes = calculate_tax(value, socket.assigns.tax_rate)
        total = calculate_total(value, taxes, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(total: total)
         |> assign(taxes: taxes)
         |> assign(value: value)}

      true ->
        item = %{product_id: product_id, quantity: 1}
        items = [item | items]

        value = calculate_value(socket.assigns.items, socket.assigns.products)
        taxes = calculate_tax(value, socket.assigns.tax_rate)
        total = calculate_total(value, socket.assigns.taxes, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(total: total)
         |> assign(taxes: taxes)
         |> assign(value: value)
         |> assign(is_saved: false)}
    end
  end

  def handle_event("change-quantity", %{"new_quantity" => new_quantity}, socket) do
    product_id = socket.assigns.product_id_to_change
    product = Inventory.get_product(socket.assigns.company_name, product_id)
    items = socket.assigns.items
    quantity = Enum.find(items, &(&1.product_id == product_id)).quantity
    new_quantity = String.to_integer(new_quantity)
    stock_diff = new_quantity - quantity

    Process.send_after(self(), :clear_flash, 1200)

    cond do
      quantity <= 0 ->
        {:noreply,
         socket
         |> put_flash(:error, "quantity must be above 0")}

      !product ->
        {:noreply,
         socket
         |> put_flash(:error, "product no longer exists")}

      product.stock < stock_diff ->
        {:noreply,
         socket
         |> put_flash(:error, "Not enough stock")}

      true ->
        items =
          Enum.map(items, fn item ->
            if item.product_id == product_id,
              do: Map.put(item, :quantity, new_quantity),
              else: item
          end)

        value = calculate_value(items, socket.assigns.products)
        total = calculate_total(value, socket.assigns.taxes, socket.assigns.discount)
        taxes = calculate_tax(value, socket.assigns.tax_rate)

        {:noreply,
         socket
         |> assign(total: total)
         |> assign(value: value)
         |> assign(items: items)
         |> assign(taxes: taxes)
         |> assign(product_id_to_change: nil)
         |> assign(is_saved: false)}
    end
  end

  def handle_event("change-item-quantity", %{"product_id" => product_id}, socket) do
    {:noreply,
     socket
     |> assign(product_id_to_change: String.to_integer(product_id))}
  end

  def handle_event("cancel-input", _, socket) do
    {:noreply,
     socket
     |> assign(product_id_to_change: nil)}
  end

  def handle_event("delete-item", %{"product_id" => product_id} = _params, socket) do
    product_id = String.to_integer(product_id)
    items = socket.assigns.items
    item = Enum.find(items, &(&1.product_id == product_id))
    Process.send_after(self(), :clear_flash, 1200)

    case Map.get(item, :id) do
      nil ->
        items = List.delete(items, item)
        value = calculate_value(items, socket.assigns.products)
        total = calculate_total(value, socket.assigns.taxes, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(total: total)
         |> assign(value: value)
         |> assign(is_saved: false)
         |> put_flash(:info, "Deleted item")}

      id ->
        saved_item = Orders.get_item(socket.assigns.company_name, socket.assigns.invoice_id, id)
        product = Inventory.get_product(socket.assigns.company_name, product_id)
        Orders.delete_item(saved_item)
        Inventory.update_product(product, %{"stock" => product.stock + saved_item.quantity})

        products = Inventory.list_products(socket.assigns.company_name)
        items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)

        value = calculate_value(items, products)
        total = calculate_total(value, socket.assigns.taxes, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(total: total)
         |> assign(value: value)
         |> assign(products: products)
         |> assign(is_saved: false)
         |> put_flash(:info, "Deleted item: #{product.name}")}
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp get_product_field(assigns, product_id, field) do
    product = Enum.find(assigns.products, &(&1.id == product_id))
    Map.get(product, field)
  end

  defp update_invoice(invoice, attrs, socket) do
    case Orders.update_invoice(invoice, attrs) do
      {:ok, _invoice} ->
        Process.send_after(self(), :clear_flash, 1000)

        products = Inventory.list_products(socket.assigns.company_name)
        items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)

        {:noreply,
         socket
         |> assign(products: products)
         |> assign(items: items)
         |> assign(is_saved: true)
         |> put_flash(:info, "Saved successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp calculate_value([], _), do: 0

  defp calculate_value(items, products) do
    items
    |> Enum.reduce(0, fn item, acc ->
      item.quantity * Decimal.to_float(Enum.find(products, &(&1.id == item.product_id)).price) +
        acc
    end)
    |> Float.round(2)
  end

  defp calculate_tax(value, tax_rate),
    do:
      (value * tax_rate / 100)
      |> Float.round(2)

  defp calculate_total(value, taxes, discount) do
    (value + taxes - discount)
    |> Float.round(2)
  end

  defp get_number(number) do
    cond do
      Regex.match?(~r/^\d+\.\d+$/, number) ->
        String.to_float(number)

      Regex.match?(~r/^\d+$/, number) ->
        String.to_integer(number)

      true ->
        0
    end
  end

  defp to_eur(0), do: "0.00 €"

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

  defp is_before?(invoice_params) do
    Map.get(invoice_params, "billing_date") < Date.to_string(Date.utc_today())
  end
end
