defmodule InvoiceManagerWeb.BrowserLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Orders

  @size 5

  def mount(%{"role" => role}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_id = user.company_id

    pagination =
      (Orders.count_invoices(company_id, role) / @size)
      |> ceil()
      |> max(1)
      |> paginate(0, 1, 0)

    socket =
      assign(socket,
        invoices: Orders.list_invoices(company_id, @size, 0, role),
        user: user,
        role: role,
        company_name: get_company_name(company_id),
        company_id: company_id,
        pagination: pagination
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <InvoiceManagerWeb.Live.Show.invoice_navigation
        company_name={@company_name}
        user_is_admin={@user.is_admin}
      />
      <div class="flex-grow mx-auto max-w-sm">
        <.table id="invoice" rows={@invoices}>
          <:col :let={invoice} label="Number">
            <span
              phx-click="open-invoice"
              phx-value-invoice_id={invoice.id}
              class="py-2 px-3 rounded focus:cursor-auto bg-teal-50 hover:bg-teal-200 hover:cursor-pointer"
            >
              <%= invoice.id %>
            </span>
          </:col>
          <:col :let={invoice} :if={@role == "incoming"} label="Company">
            <%= get_company_name(invoice.company_id) %>
          </:col>
          <:col :let={invoice} :if={@role == "outgoing"} label="Customer">
            <%= get_company_name(invoice.customer_id) %>
          </:col>
          <:col :let={invoice} label="Total"><%= to_euro(invoice.total) %></:col>
          <:col :let={invoice} label="Billing Date">
            <%= "#{invoice.billing_date.month} / #{invoice.billing_date.day} / #{invoice.billing_date.year}" %>
          </:col>
        </.table>
        <InvoiceManagerWeb.Live.Show.pagination pagination={@pagination} />
      </div>
    </div>
    """
  end

  def handle_event("change-page", %{"direction" => direction}, socket) do
    move = if direction == "right", do: 1, else: -1
    pagination = socket.assigns.pagination
    offset = pagination.offset + @size * move

    {:noreply,
     assign(socket,
       pagination: paginate(pagination.pages, offset, pagination.page_num, move),
       invoices:
         Orders.list_invoices(socket.assigns.company_id, @size, offset, socket.assigns.role)
     )}
  end

  def handle_event("open-invoice", %{"invoice_id" => invoice_id}, socket) do
    {:noreply,
     socket
     |> redirect(to: ~p"/invoice_manager/browser/#{socket.assigns.role}/#{invoice_id}")}
  end
end
