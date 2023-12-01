defmodule InvoiceManagerWeb.EditorLive do
  alias InvoiceManager.Inventory
  use InvoiceManagerWeb, :live_view
  alias InvoiceManager.Orders.Invoice
  alias InvoiceManager.Orders

  def mount(%{"company_name" => company_name}, _session, socket) do
    invoice_changeset = Orders.change_invoice(%Invoice{})
    products = Inventory.list_products(company_name)

    socket =
      assign(socket,
        company_name: company_name,
        form: to_form(invoice_changeset),
        products: products,
        items: [],
        new_item: true,
        total: 0
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
    case Orders.create_invoice(socket.assigns.company_name, invoice_params) do
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

    if product in socket.assigns.items do
      {:noreply,
       socket
       |> put_flash(:error, "Already selected #{product.name}")}
    else
      {:noreply,
       socket
       |> assign(items: socket.assigns.items ++ [product])
       |> assign(total: socket.assigns.total + Decimal.to_float(product.price))
       |> put_flash(:info, "Selected product with id: #{product_id}")}
    end
  end

  def handle_event("add", %{"item_id" => id} = _params, socket) do
    item = Enum.find(socket.assigns.items, &(&1.id == String.to_integer(id)))
    product = Enum.find(socket.assigns.products, &(&1.id == String.to_integer(id)))

    cond do
      !product ->
        {:noreply,
         socket
         |> put_flash(:error, "product no longer exists")}

      product.stock == 0 ->
        {:noreply,
         socket
         |> put_flash(:error, "Out of stock")}

      true ->
        # Add item amount
        # Orders.add_one(company_name, invoice_id, item_id)
        # Substract one from stock
        # Inventory.substract_one(company_name, product_id)
        {:noreply,
         socket
         |> assign(total: socket.assigns.total + Decimal.to_float(item.price))
         |> put_flash(:info, "Add item with id: #{id}")}
    end
  end

  def handle_event("substract", %{"item_id" => id} = _params, socket) do
    item = Enum.find(socket.assigns.items, &(&1.id == String.to_integer(id)))

    cond do
      item.stock == 0 ->
        {:noreply,
         socket
         |> put_flash(:error, "Already 0")}

      true ->
        # Substract item amount
        # Orders.substract_one(company_name, invoice_id, item_id)
        # Add one to stock
        # Inventory.add_one(company_name, product_id)
        {:noreply,
         socket
         |> assign(total: socket.assigns.total - Decimal.to_float(item.price))
         |> put_flash(:info, "Sub item with id: #{id}")}
    end
  end
end
