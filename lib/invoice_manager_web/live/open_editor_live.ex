defmodule InvoiceManagerWeb.OpenEditorLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Orders

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    invoices = Orders.list_unsent_invoices(user.company_id)

    socket =
      assign(socket,
        company_name: Business.get_company!(user.company_id).name,
        company_id: user.company_id,
        form: to_form(%{}, as: "customer"),
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
    invoice = Orders.get_invoice!(invoice_id)
    Orders.delete_invoice(invoice)

    {:noreply,
     socket
     |> assign(invoices: Orders.list_unsent_invoices(socket.assigns.company_id))}
  end

  defp get_company_name(company_id), do: Business.get_company_name(company_id)
end
