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
    invoice_changeset = Orders.change_invoice(%Invoice{})
    products = Inventory.list_products(company_name)
    items = Orders.list_items(company_name, invoice_id)
    value = calculate_value(items, products)
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
        discount: 0.0,
        tax_rate: 0.0,
        new_item: true,
        value: value,
        total: value,
        deleting: false
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

    items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)

    products = Inventory.list_products(socket.assigns.company_name)

    value = calculate_value(items, products)

    total = calculate_total(value, tax_rate, discount)

    {:noreply,
     assign(socket, form: form)
     |> assign(discount: discount)
     |> assign(value: value)
     |> assign(tax_rate: tax_rate)
     |> assign(total: total)}
  end

  def handle_event("send", %{"invoice" => invoice_params}, socket) do
    cond do
      socket.assigns.total <= 0 ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Total should be higher than 0")}

      Map.get(invoice_params, "billing_date") < Date.to_string(Date.utc_today()) ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Billing date cannot be before today")}

      true ->
        invoice = Orders.get_invoice(socket.assigns.company_name, socket.assigns.invoice_id)

        Orders.fix_items_price_and_name(socket.assigns.items, socket.assigns.products)

        attrs =
          invoice_params
          |> Map.put("sent", true)
          |> Map.put("operation_date", Date.utc_today())
          |> Map.put("total", socket.assigns.total)
          |> Map.put("discount", socket.assigns.discount)
          |> Map.put("invoice_number", socket.assigns.invoice_id)

        send_and_update_invoice(invoice, attrs, socket)
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

  def handle_event("select_item", %{"item_id" => product_id} = _params, socket) do
    product = Inventory.get_product!(product_id)

    Process.send_after(self(), :clear_flash, 1200)

    if !product or product.stock == 0 do
      {:noreply,
       socket
       |> put_flash(:error, "Out of stock")}
    else
      case Orders.create_item(product.id, socket.assigns.company_name, socket.assigns.invoice_id) do
        {:ok, _item} ->
          Inventory.update_product(product, :subtract)
          products = Inventory.list_products(socket.assigns.company_name)
          items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)
          value = calculate_value(items, products)
          total = calculate_total(value, socket.assigns.tax_rate, socket.assigns.discount)

          {:noreply,
           socket
           |> assign(items: items)
           |> assign(total: total)
           |> assign(value: value)
           |> assign(products: products)
           |> assign(item: items)}

        {:error, %Ecto.Changeset{} = _changeset} ->
          {:noreply,
           socket
           |> put_flash(:error, "Already added product.")}
      end
    end
  end

  def handle_event("add", %{"item_id" => id} = _params, socket) do
    item = Orders.get_item(socket.assigns.company_name, socket.assigns.invoice_id, id)

    product = Inventory.get_product(socket.assigns.company_name, item.product_id)

    cond do
      !product ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "product no longer exists")}

      product.stock == 0 ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Out of stock")}

      true ->
        Orders.update_item(item, :add)

        Inventory.update_product(product, :subtract)

        items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)

        products = Inventory.list_products(socket.assigns.company_name)

        value = calculate_value(items, products)
        total = calculate_total(value, socket.assigns.tax_rate, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(total: total)
         |> assign(value: value)
         |> assign(products: products)
         |> assign(items: items)}
    end
  end

  def handle_event("subtract", %{"item_id" => id} = _params, socket) do
    item = Orders.get_item(socket.assigns.company_name, socket.assigns.invoice_id, id)

    product = Inventory.get_product(socket.assigns.company_name, item.product_id)

    cond do
      item.quantity == 0 ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, "Already 0")}

      true ->
        Orders.update_item(item, :subtract)
        Inventory.update_product(product, :add)
        items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)
        products = Inventory.list_products(socket.assigns.company_name)
        value = calculate_value(items, products)
        total = calculate_total(value, socket.assigns.tax_rate, socket.assigns.discount)

        {:noreply,
         socket
         |> assign(value: value)
         |> assign(total: total)
         |> assign(products: products)
         |> assign(items: items)}
    end
  end

  def handle_event("change-deleting-option", _, socket) do
    {:noreply,
     socket
     |> assign(deleting: !socket.assigns.deleting)}
  end

  def handle_event("delete-item", %{"item_id" => item_id} = _params, socket) do
    item = Orders.get_item(socket.assigns.company_name, socket.assigns.invoice_id, item_id)
    product = Inventory.get_product(socket.assigns.company_name, item.product_id)
    Orders.delete_item(item)
    Inventory.update_product(product, :add, item.quantity)
    Process.send_after(self(), :clear_flash, 1200)

    items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)
    products = Inventory.list_products(socket.assigns.company_name)
    value = calculate_value(items, products)
    total = calculate_total(value, socket.assigns.tax_rate, socket.assigns.discount)

    {:noreply,
     socket
     |> assign(items: items)
     |> assign(total: total)
     |> assign(value: value)
     |> assign(products: products)
     |> assign(deleting: false)
     |> put_flash(:info, "Deleted item: #{product.name}")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp get_product_field(assigns, product_id, field) do
    product = Enum.find(assigns.products, &(&1.id == product_id))
    Map.get(product, field)
  end

  defp send_and_update_invoice(invoice, attrs, socket) do
    case Orders.update_invoice(invoice, attrs) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> assign(invoice: invoice)
         |> put_flash(:info, "invoice sent")
         |> redirect(to: ~p"/invoice_manager/#{socket.assigns.company_name}")}

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

  defp calculate_total(value, tax_rate, discount) do
    (value + calculate_tax(value, tax_rate) - discount)
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
end
