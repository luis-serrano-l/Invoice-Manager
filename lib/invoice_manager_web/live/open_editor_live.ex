defmodule InvoiceManagerWeb.OpenEditorLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Accounts
  alias InvoiceManager.Orders
  use InvoiceManagerWeb, :live_view

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_name = Business.get_company!(user.company_id).name

    invoices = Orders.list_unsent_invoices(company_name)

    socket =
      assign(socket,
        company_name: company_name,
        form: to_form(%{}, as: "customer"),
        company_name: company_name,
        user_is_admin: user.is_admin,
        invoices: invoices
      )

    {:ok, socket}
  end

  def handle_event("create", %{"customer" => %{"name" => customer_name}}, socket) do
    case Orders.create_invoice(socket.assigns.company_name, customer_name) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> redirect(
           to:
             ~p"/invoice_manager/#{socket.assigns.company_name}/editor/#{customer_name}/#{invoice.id}"
         )}

      {:error, message} ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> assign(form: to_form(%{"name" => customer_name}, as: "customer"))
         |> put_flash(:error, message)}
    end
  end

  def handle_event(
        "open-invoice",
        %{"invoice_id" => invoice_id, "customer_id" => customer_id},
        socket
      ) do
    customer_name = Business.get_company_name(customer_id)

    {:noreply,
     socket
     |> redirect(
       to:
         ~p"/invoice_manager/#{socket.assigns.company_name}/editor/#{customer_name}/#{invoice_id}"
     )}
  end

  def handle_event("delete-invoice", %{"invoice_id" => invoice_id}, socket) do
    invoice = Orders.get_invoice(socket.assigns.company_name, invoice_id)
    Orders.delete_invoice(invoice)
    invoices = Orders.list_unsent_invoices(socket.assigns.company_name)

    {:noreply,
     socket
     |> assign(invoices: invoices)}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  defp get_company_name(company_id), do: Business.get_company_name(company_id)
end
