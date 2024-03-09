defmodule InvoiceManagerWeb.EditorLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Inventory
  alias InvoiceManager.Orders
  alias InvoiceManager.Orders.Invoice

  @size 5

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
    invoice_id = String.to_integer(invoice_id)
    invoice = Orders.get_invoice!(invoice_id)
    items = Orders.list_items(invoice_id)
    company_id = user.company_id

    socket =
      assign(socket,
        user_is_admin: user.is_admin,
        items: items,
        item_params: [],
        products: Inventory.list_products(company_id, @size, 0),
        product_search: "",
        invoice_id: invoice_id,
        company_id: company_id,
        customer_name: customer_name,
        company_name: get_company_name(company_id),
        form: to_form(Orders.change_invoice(invoice)),
        operation_date: Date.utc_today(),
        costs: get_costs(items, invoice.tax_rate, invoice.discount),
        pagination: new_paginate(company_id, @size),
        options: %{product_id_to_change: nil, new_item: true, is_saved: false}
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

  def handle_event("validate", %{"invoice" => params}, socket) do
    %{"discount" => discount, "tax_rate" => tax_rate} = params
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

    {:noreply,
     assign(socket, form: form)
     |> assign(costs: get_costs(items, tax_rate, discount))
     |> assign(options: Map.put(socket.assigns.options, :is_saved, false))}
  end

  def handle_event("send", _, socket) do
    if !socket.assigns.options.is_saved do
      {:noreply, put_flash(socket, :error, "Cannot send before saving")}
    else
      invoice = Orders.get_invoice!(socket.assigns.invoice_id)
      {:ok, invoice} = Orders.update_invoice(invoice, %{"sent" => true})

      {:noreply,
       socket
       |> put_flash(:info, "invoice sent")
       |> redirect(to: ~p"/invoice_manager/#{get_company_name(socket.assigns.company_id)}")}
    end
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    cond do
      socket.assigns.costs.total <= 0 ->
        {:noreply, put_flash(socket, :error, "Total should be higher than 0")}

      is_before?(invoice_params) ->
        {:noreply, put_flash(socket, :error, "Billing date cannot be before today")}

      true ->
        Orders.update_items_and_products(
          socket.assigns.invoice_id,
          socket.assigns.items
        )

        attrs =
          change_map(
            invoice_params,
            %{
              "operation_date" => Date.utc_today(),
              "total" => socket.assigns.costs.total,
              "invoice_number" => socket.assigns.invoice_id
            }
          )

        invoice = Orders.get_invoice!(socket.assigns.invoice_id)

        update_invoice(invoice, attrs, socket)
    end
  end

  def handle_event("show-hide-inventory", _, socket) do
    options = socket.assigns.options

    {:noreply,
     socket
     |> assign(options: Map.put(options, :new_item, !options.new_item))}
  end

  def handle_event("select_item", %{"product_id" => product_id} = _params, socket) do
    product_id = String.to_integer(product_id)
    product = Inventory.get_product!(product_id)
    items = socket.assigns.items

    cond do
      !product or product.stock == 0 ->
        {:noreply, put_flash(socket, :error, "Out of stock")}

      product_id in Enum.map(items, & &1.product_id) ->
        {:noreply,
         socket
         |> assign(items: change_item_quantity(items, product_id, 1, 1))
         |> assign(
           costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
         )}

      true ->
        product = Inventory.get_product!(product_id)
        item = %{product_id: product_id, quantity: 1, price: product.price, name: product.name}

        {:noreply,
         socket
         |> assign(items: [item | items])
         |> assign(
           costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
         )
         |> assign(options: Map.put(socket.assigns.options, :is_saved, false))}
    end
  end

  def handle_event("change-quantity", %{"new_quantity" => new_quantity}, socket) do
    product_id_to_change = socket.assigns.options.product_id_to_change
    product = Inventory.get_product!(product_id_to_change)
    new_quantity = String.to_integer(new_quantity)
    items = socket.assigns.items

    cond do
      !product ->
        {:noreply, put_flash(socket, :error, "product no longer exists")}

      product.stock < new_quantity ->
        {:noreply, put_flash(socket, :error, "Only #{product.stock} left in stock")}

      true ->
        {:noreply,
         socket
         |> assign(items: change_item_quantity(items, product_id_to_change, new_quantity))
         |> assign(
           costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
         )
         |> assign(
           options:
             change_map(socket.assigns.options, %{product_id_to_change: nil, is_saved: false})
         )}
    end
  end

  def handle_event("change-item-quantity", %{"product_id" => product_id}, socket) do
    {:noreply,
     socket
     |> assign(
       options:
         Map.put(socket.assigns.options, :product_id_to_change, String.to_integer(product_id))
     )}
  end

  def handle_event("cancel-input", _, socket) do
    {:noreply,
     socket
     |> assign(options: Map.put(socket.assigns.options, :product_id_to_change, nil))}
  end

  def handle_event("delete-item", %{"product_id" => product_id} = _params, socket) do
    product_id = String.to_integer(product_id)
    items = socket.assigns.items
    item = Enum.find(items, &(&1.product_id == product_id))

    case Map.get(item, :id) do
      nil ->
        items = List.delete(items, item)
        costs = get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(costs: costs)
         |> assign(options: Map.put(socket.assigns.options, :is_saved, false))
         |> put_flash(:info, "Deleted item")}

      id ->
        saved_item = Orders.get_item!(id)
        product = Inventory.get_product!(product_id)
        Orders.delete_item(saved_item)
        Inventory.update_product(product, %{"stock" => product.stock + saved_item.quantity})
        items = Orders.list_items(socket.assigns.invoice_id)
        costs = get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)

        {:noreply,
         socket
         |> assign(items: items)
         |> assign(costs: costs)
         |> assign(
           products:
             Inventory.list_products(
               socket.assigns.company_id,
               @size,
               socket.assigns.pagination.offset
             )
         )
         |> assign(options: Map.put(socket.assigns.options, :is_saved, false))
         |> put_flash(:info, "Deleted item: #{product.name}")}
    end
  end

  defp update_invoice(invoice, attrs, socket) do
    case Orders.update_invoice(invoice, attrs) do
      {:ok, _invoice} ->
        products =
          Inventory.list_products(
            socket.assigns.company_id,
            @size,
            socket.assigns.pagination.offset
          )

        items = Orders.list_items(socket.assigns.invoice_id)

        {:noreply,
         socket
         |> assign(products: products)
         |> assign(items: items)
         |> assign(options: Map.put(socket.assigns.options, :is_saved, true))
         |> put_flash(:info, "Saved successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp change_item_quantity(items, product_id_to_change, quantity, add \\ 0) do
    for item <- items do
      if item.product_id == product_id_to_change do
        %{item | quantity: item.quantity * add + quantity}
      else
        item
      end
    end
  end

  defp get_number(""), do: 0

  defp get_number(number) do
    {float, _rest} = Float.parse(number)
    float
  end

  defp is_before?(invoice_params) do
    Map.get(invoice_params, "billing_date") < Date.to_string(Date.utc_today())
  end
end
