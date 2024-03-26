defmodule InvoiceManagerWeb.EditorLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Inventory
  alias InvoiceManager.Orders
  alias InvoiceManager.Orders.Invoice

  @size 7

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
    items = Orders.list_items(invoice_id) |> Orders.update_item_price_and_name()
    company_id = user.company_id

    pagination =
      (Inventory.count_products(company_id) / @size)
      |> ceil()
      |> max(1)
      |> paginate(0, 1, 0)

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
        pagination: pagination,
        options: %{product_id_to_change: nil, new_item: true, is_saved: false}
      )

    {:ok, socket}
  end

  def handle_event("search", %{"product_search" => product_search}, socket) do
    {:noreply,
     socket
     |> assign(products: Inventory.search_products(socket.assigns.company_id, product_search))
     |> assign(product_search: product_search)}
  end

  def handle_event("change-page", %{"direction" => direction}, socket) do
    move = if direction == "right", do: 1, else: -1
    pagination = socket.assigns.pagination
    offset = pagination.offset + @size * move

    {:noreply,
     assign(socket,
       pagination: paginate(pagination.pages, offset, pagination.page_num, move),
       products: Inventory.list_products(socket.assigns.company_id, @size, offset)
     )}
  end

  def handle_event("validate", %{"invoice" => params}, socket) do
    %{"discount" => discount, "tax_rate" => tax_rate} = params
    discount = get_number(discount)
    tax_rate = get_number(tax_rate)
    params = change_map(params, %{"discount" => discount, "tax_rate" => tax_rate})

    form =
      %Invoice{}
      |> Orders.change_invoice(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply,
     assign(socket, form: form)
     |> assign(costs: get_costs(socket.assigns.items, tax_rate, discount))
     |> assign(options: Map.put(socket.assigns.options, :is_saved, false))}
  end

  def handle_event("send", _, socket) when socket.assigns.options.is_saved do
    case Inventory.update_each_product_stock(socket.assigns.company_id, socket.assigns.items) do
      {:ok, _company} ->
        invoice = Orders.get_invoice!(socket.assigns.invoice_id)
        {:ok, _invoice} = Orders.update_invoice(invoice, %{"sent" => true})

        {:noreply,
         socket
         |> put_flash(:info, "invoice sent")
         |> redirect(to: ~p"/invoice_manager/#{get_company_name(socket.assigns.company_id)}")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Some product does not have enough stock")}
    end
  end

  def handle_event("send", _, socket) do
    {:noreply, put_flash(socket, :error, "Cannot send before saving")}
  end

  def handle_event("save", %{"invoice" => invoice_params}, socket) do
    case error(socket.assigns.items, socket.assigns.costs, invoice_params) do
      nil ->
        attrs =
          change_map(invoice_params, %{
            "operation_date" => Date.utc_today(),
            "total" => socket.assigns.costs.total
          })

        case Orders.update_full_invoice(socket.assigns.invoice_id, socket.assigns.items, attrs) do
          {:ok, _invoice} ->
            {:noreply,
             socket
             |> assign(options: Map.put(socket.assigns.options, :is_saved, true))
             |> put_flash(:info, "Saved successfully")}

          {:error, %Ecto.Changeset{} = changeset} ->
            {:noreply, assign(socket, form: to_form(changeset))}
        end

      message ->
        {:noreply, put_flash(socket, :error, message)}
    end
  end

  def handle_event("show-hide-inventory", _, socket) do
    options = socket.assigns.options

    {:noreply,
     socket
     |> assign(options: Map.put(options, :new_item, !options.new_item))}
  end

  def handle_event("cancel-input", _, socket) do
    {:noreply,
     socket
     |> assign(options: Map.put(socket.assigns.options, :product_id_to_change, nil))}
  end

  def handle_event("select_item", %{"product_id" => product_id} = _params, socket) do
    product_id = String.to_integer(product_id)
    items = socket.assigns.items

    if product_id in Enum.map(items, & &1.product_id) do
      items = increase_item_quantity(items, product_id)

      {:noreply,
       socket
       |> assign(items: items)
       |> assign(
         costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
       )}
    else
      product = Inventory.get_product!(product_id)
      item = %{product_id: product_id, quantity: 1, price: product.price, name: product.name}
      items = [item | items]

      {:noreply,
       socket
       |> assign(items: items)
       |> assign(
         costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
       )
       |> assign(options: Map.put(socket.assigns.options, :is_saved, false))}
    end
  end

  def handle_event("change-quantity", %{"new_quantity" => new_quantity}, socket) do
    product_id_to_change = socket.assigns.options.product_id_to_change
    new_quantity = String.to_integer(new_quantity)

    items = set_item_quantity(socket.assigns.items, product_id_to_change, new_quantity)

    {:noreply,
     socket
     |> assign(items: items)
     |> assign(
       costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
     )
     |> assign(
       options: change_map(socket.assigns.options, %{product_id_to_change: nil, is_saved: false})
     )}
  end

  def handle_event("select-item-to-change-quantity", %{"product_id" => product_id}, socket) do
    {:noreply,
     socket
     |> assign(
       options:
         Map.put(socket.assigns.options, :product_id_to_change, String.to_integer(product_id))
     )}
  end

  def handle_event("delete-item", %{"product_id" => product_id} = _params, socket) do
    items = socket.assigns.items
    item = Enum.find(items, &(&1.product_id == String.to_integer(product_id)))
    items = List.delete(items, item)

    {:noreply,
     socket
     |> assign(items: items)
     |> assign(
       costs: get_costs(items, socket.assigns.costs.tax_rate, socket.assigns.costs.discount)
     )
     |> assign(options: Map.put(socket.assigns.options, :is_saved, false))}
  end

  @spec increase_item_quantity(list(struct()), pos_integer()) :: list(struct())
  defp increase_item_quantity(items, product_id_to_change) do
    for item <- items do
      if item.product_id == product_id_to_change do
        %{item | quantity: item.quantity + 1}
      else
        item
      end
    end
  end

  @spec set_item_quantity(list(struct()), pos_integer(), non_neg_integer()) :: list(struct())
  defp set_item_quantity(items, product_id_to_change, new_quantity) do
    for item <- items do
      if item.product_id == product_id_to_change do
        %{item | quantity: new_quantity}
      else
        item
      end
    end
  end

  @spec get_number(String.t()) :: float() | 0
  defp get_number(""), do: 0

  defp get_number(number) do
    {float, _rest} = Float.parse(number)
    float
  end

  @spec before?(map()) :: boolean()
  defp before?(invoice_params) do
    Map.get(invoice_params, "billing_date") < Date.to_string(Date.utc_today())
  end

  @spec error(list(struct()), map(), map()) :: String.t() | nil
  defp error(items, costs, invoice_params) do
    cond do
      stock_unavailable?(items) ->
        {:error, {name, stock}} = stock_unavailable?(items)
        "Only #{stock} #{name} available in stock"

      costs.total <= 0 ->
        "Total should be higher than 0"

      before?(invoice_params) ->
        "Billing date cannot be before today"

      true ->
        nil
    end
  end

  @spec stock_unavailable?(list(struct())) :: tuple() | false
  defp stock_unavailable?([]), do: false

  defp stock_unavailable?([item | rest]) do
    product = Inventory.get_product!(item.product_id)

    if product.stock >= item.quantity do
      stock_unavailable?(rest)
    else
      {:error, {product.name, product.stock}}
    end
  end
end
