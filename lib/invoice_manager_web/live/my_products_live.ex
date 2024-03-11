defmodule InvoiceManagerWeb.MyProductsLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Inventory
  alias InvoiceManager.Inventory.Product

  @size 20

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_id = user.company_id

    socket =
      assign(socket,
        user: user,
        company_id: company_id,
        products: Inventory.list_products(company_id, @size, 0),
        company_name: Business.get_company_name(company_id),
        form: to_form(Inventory.change_product(%Product{})),
        user_is_admin: user.is_admin,
        pagination: new_paginate(company_id, @size),
        product_search: "",
        options: %{
          new_product: true,
          changing_inventory: false,
          product_field_to_change: "",
          product_id_to_change: nil
        }
      )

    {:ok, socket}
  end

  def handle_event("search", %{"product_search" => product_search}, socket) do
    products = Inventory.search_products(socket.assigns.company_id, product_search)

    {:noreply,
     socket
     |> assign(products: products)
     |> assign(product_search: product_search)}
  end

  def handle_event("change-page", %{"direction" => direction}, socket) do
    pagination = socket.assigns.pagination
    company_id = socket.assigns.company_id

    case {{pagination.page_num, pagination.pages}, direction} do
      {{last, last}, "right"} ->
        {:noreply, put_flash(socket, :error, "Reached last page")}

      {{1, _}, "left"} ->
        {:noreply, put_flash(socket, :error, "Already first page")}

      {_, "right"} ->
        {:noreply, assign(socket, change_page(company_id, pagination, 1, @size))}

      {_, "left"} ->
        {:noreply, assign(socket, change_page(company_id, pagination, -1, @size))}
    end
  end

  def handle_event("validate", %{"product" => params}, socket) do
    form =
      %Product{}
      |> Inventory.change_product(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("add", %{"product" => params}, socket) do
    params = convert_price_to_float(params)

    case Inventory.create_product(socket.assigns.company_id, params) do
      {:ok, product} ->
        product_changeset = Inventory.change_product(%Product{})

        {:noreply,
         socket
         |> assign(products: socket.assigns.products ++ [product])
         |> assign(form: to_form(product_changeset))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("show-hide-input", _, socket) do
    options = socket.assigns.options

    {:noreply,
     socket
     |> assign(options: Map.put(options, :new_product, !options.new_product))}
  end

  def handle_event("change-inventory-option", _, socket) do
    options = socket.assigns.options

    {:noreply,
     socket
     |> assign(
       options:
         change_map(options, %{
           changing_inventory: !options.changing_inventory,
           product_id_to_change: nil
         })
     )}
  end

  def handle_event("update-product", %{"product_input" => product_input} = _params, socket) do
    product = Inventory.get_product!(socket.assigns.options.product_id_to_change)

    case Inventory.update_product(product, %{
           socket.assigns.options.product_field_to_change => product_input
         }) do
      {:ok, _product} ->
        products =
          Inventory.list_products(
            socket.assigns.company_id,
            @size,
            socket.assigns.pagination.offset
          )

        {:noreply,
         socket
         |> assign(products: products)
         |> assign(
           options:
             change_map(socket.assigns.options, %{
               product_id_to_change: nil,
               product_field_to_change: ""
             })
         )}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("change-product", %{"product_id" => product_id, "field" => field}, socket) do
    {:noreply,
     socket
     |> assign(
       options:
         change_map(socket.assigns.options, %{
           product_id_to_change: String.to_integer(product_id),
           product_field_to_change: field
         })
     )}
  end

  defp convert_price_to_float(params) do
    {float, _} = Float.parse(params["price"])
    Map.put(params, "price", float)
  end
end
