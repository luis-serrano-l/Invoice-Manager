defmodule InvoiceManagerWeb.MyProductsLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Accounts
  alias InvoiceManager.Inventory.Product
  alias InvoiceManager.Inventory
  use InvoiceManagerWeb, :live_view

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_name = Business.get_company!(user.company_id).name
    products = Inventory.list_products(company_name)
    product_changeset = Inventory.change_product(%Product{})

    socket =
      assign(socket,
        products: products,
        company_name: company_name,
        form: to_form(product_changeset),
        new_product: false,
        changing_inventory: false,
        product_id_to_change: nil,
        product_field_to_change: "",
        user_is_admin: user.is_admin
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
         |> assign(form: to_form(product_changeset))}

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

  def handle_event("change-inventory-option", _, socket) do
    {:noreply,
     socket
     |> assign(changing_inventory: !socket.assigns.changing_inventory)
     |> assign(product_id_to_change: nil)}
  end

  def handle_event("update-product", %{"product_input" => product_input} = _params, socket) do
    product =
      Inventory.get_product(socket.assigns.company_name, socket.assigns.product_id_to_change)

    Process.send_after(self(), :clear_flash, 1400)

    case Inventory.update_product(product, %{
           socket.assigns.product_field_to_change => product_input
         }) do
      {:ok, _product} ->
        products = Inventory.list_products(socket.assigns.company_name)

        {:noreply,
         socket
         |> assign(products: products)
         |> assign(product_id_to_change: nil)
         |> assign(product_field_to_change: "")}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("change-product-name", %{"product_id" => product_id}, socket) do
    Process.send_after(self(), :clear_flash, 1200)

    {:noreply,
     socket
     |> assign(product_id_to_change: String.to_integer(product_id))
     |> assign(product_field_to_change: "name")}
  end

  def handle_event("change-product-price", %{"product_id" => product_id}, socket) do
    Process.send_after(self(), :clear_flash, 1200)

    {:noreply,
     socket
     |> assign(product_id_to_change: String.to_integer(product_id))
     |> assign(product_field_to_change: "price")}
  end

  def handle_event("change-product-stock", %{"product_id" => product_id}, socket) do
    Process.send_after(self(), :clear_flash, 1200)

    {:noreply,
     socket
     |> assign(product_id_to_change: String.to_integer(product_id))
     |> assign(product_field_to_change: "stock")}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
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
