defmodule InvoiceManagerWeb.MyProductsLive do
  alias InvoiceManager.Inventory.Product
  alias InvoiceManager.Inventory
  use InvoiceManagerWeb, :live_view

  def mount(%{"company_name" => company_name}, _session, socket) do
    products = Inventory.list_products(company_name)
    product_changeset = Inventory.change_product(%Product{})

    socket =
      assign(socket,
        products: products,
        company_name: company_name,
        form: to_form(product_changeset),
        new_product: false,
        deleting: false,
        changing_stock: false,
        product_id_to_change: nil
      )

    {:ok, socket}
  end

  def handle_event("validate", %{"product" => params}, socket) do
    form =
      %Product{}
      |> Inventory.change_product(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("add", %{"product" => product_params}, socket) do
    case Inventory.create_product(socket.assigns.company_name, product_params) do
      {:ok, product} ->
        product_changeset = Inventory.change_product(%Product{})

        {:noreply,
         socket
         |> assign(products: socket.assigns.products ++ [product])
         |> assign(new_product: false)
         |> assign(form: to_form(product_changeset))
         |> put_flash(:info, "product added")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("new_product", _, socket) do
    {:noreply,
     socket
     |> assign(new_product: true)}
  end

  def handle_event("hide", _, socket) do
    {:noreply,
     socket
     |> assign(new_product: false)}
  end

  def handle_event("change-stock-option", _, socket) do
    {:noreply,
     socket
     |> assign(changing_stock: !socket.assigns.changing_stock)
     |> assign(product_id_to_change: nil)}
  end

  def handle_event("update-stock", %{"quantity" => quantity} = _params, socket) do
    product =
      Inventory.get_product(socket.assigns.company_name, socket.assigns.product_id_to_change)

    Process.send_after(self(), :clear_flash, 1400)

    case Inventory.update_product(product, :add, String.to_integer(quantity)) do
      {:ok, _product} ->
        products = Inventory.list_products(socket.assigns.company_name)

        {:noreply,
         socket
         |> assign(products: products)
         |> assign(product_id_to_change: nil)
         |> put_flash(:info, "changed stock in #{product.name}")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Stock cannot be lower than 0")}
    end
  end

  def handle_event("change-product-stock", %{"product_id" => product_id}, socket) do
    Process.send_after(self(), :clear_flash, 1200)

    {:noreply,
     socket
     |> assign(product_id_to_change: String.to_integer(product_id))}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
