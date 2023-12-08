defmodule InvoiceManagerWeb.EditorLive do
  alias InvoiceManager.Inventory
  use InvoiceManagerWeb, :live_view
  alias InvoiceManager.Orders.Invoice
  alias InvoiceManager.Orders

  def mount(
        %{
          "company_name" => company_name,
          "customer_name" => customer_name,
          "invoice_id" => invoice_id
        },
        _session,
        socket
      ) do
    invoice_id = String.to_integer(invoice_id)
    invoice_changeset = Orders.change_invoice(%Invoice{})
    products = Inventory.list_products(company_name)
    items = Orders.list_items(company_name, invoice_id)
    total = calculate_total(items, products)
    Process.send_after(self(), :clear_flash, 1000)

    socket =
      assign(socket,
        company_name: company_name,
        customer_name: customer_name,
        invoice_id: invoice_id,
        form: to_form(invoice_changeset),
        products: products,
        items: items,
        new_item: true,
        total: total,
        deleting: false
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"invoice" => params}, socket) do
    form =
      %Invoice{}
      |> Orders.change_invoice(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    invoice = Orders.get_invoice!(socket.assigns.invoice_id)

    Process.send_after(self(), :clear_flash, 1500)

    case Orders.update_invoice(invoice, invoice_params) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> assign(invoice: invoice)
         |> put_flash(:info, "invoice saved")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
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

    if product.stock == 0 do
      {:noreply,
       socket
       |> put_flash(:error, "Out of stock")}
    else
      case Orders.create_item(product.id, socket.assigns.company_name, socket.assigns.invoice_id) do
        {:ok, _item} ->
          Inventory.update_product(product, :subtract)
          products = Inventory.list_products(socket.assigns.company_name)
          items = Orders.list_items(socket.assigns.company_name, socket.assigns.invoice_id)

          {:noreply,
           socket
           |> assign(items: items)
           |> assign(total: socket.assigns.total + Decimal.to_float(product.price))
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

        total = calculate_total(items, products)

        {:noreply,
         socket
         |> assign(total: total)
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
        total = calculate_total(items, products)

        {:noreply,
         socket
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
    total = calculate_total(items, products)

    {:noreply,
     socket
     |> assign(items: items)
     |> assign(products: products)
     |> assign(total: total)
     |> put_flash(:info, "Deleted item: #{product.name}")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def get_product_field(assigns, product_id, field) do
    product = Enum.find(assigns.products, &(&1.id == product_id))
    Map.get(product, field)
  end

  defp calculate_total(items, products) do
    items
    |> Enum.reduce(0, fn item, acc ->
      item.quantity * Decimal.to_float(Enum.find(products, &(&1.id == item.product_id)).price) +
        acc
    end)
  end
end
