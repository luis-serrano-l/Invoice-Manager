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
        new_product: false
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
end
