defmodule InvoiceManagerWeb.ViewInvoiceLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Orders

  def mount(
        %{"role" => role, "invoice_id" => invoice_id},
        session,
        socket
      ) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    invoice_id = String.to_integer(invoice_id)
    invoice = Orders.get_invoice!(invoice_id)

    if has_access?(role, invoice, user.company_id) do
      items = Orders.list_items(invoice_id)

      socket =
        assign(socket,
          invoice: invoice,
          items: items,
          costs: get_costs(items, invoice.tax_rate, invoice.discount),
          customer: Business.get_company!(invoice.customer_id),
          company: Business.get_company!(invoice.company_id),
          user_is_admin: user.is_admin
        )

      {:ok, socket}
    else
      {:noreply,
       socket
       |> redirect(to: ~p"/invoice_manager/browser/#{role}")
       |> put_flash(:error, "Access denied")}
    end
  end

  @spec has_access?(String.t(), struct(), integer()) :: boolean()
  defp has_access?("outgoing", invoice, my_company_id) do
    invoice.company_id == my_company_id
  end

  defp has_access?("incoming", invoice, my_company_id) do
    invoice.customer_id == my_company_id and invoice.sent
  end
end
