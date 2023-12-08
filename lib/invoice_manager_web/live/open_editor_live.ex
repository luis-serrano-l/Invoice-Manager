defmodule InvoiceManagerWeb.OpenEditorLive do
  alias InvoiceManager.Orders
  use InvoiceManagerWeb, :live_view

  def mount(%{"company_name" => company_name}, _session, socket) do
    socket =
      assign(socket,
        company_name: company_name,
        form: to_form(%{}, as: "customer")
      )

    {:ok, socket}
  end

  def handle_event("create", %{"customer" => %{"name" => customer_name}}, socket) do
    case Orders.create_invoice(socket.assigns.company_name, customer_name) do
      {:ok, invoice} ->
        {:noreply,
         socket
         |> put_flash(:info, "Invoice created")
         |> redirect(
           to:
             ~p"/invoice_manager/#{socket.assigns.company_name}/editor/#{customer_name}/#{invoice.id}"
         )}

      {:error, message} ->
        Process.send_after(self(), :clear_flash, 1200)

        {:noreply,
         socket
         |> put_flash(:error, message)}
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
