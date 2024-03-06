defmodule InvoiceManagerWeb.BrowserLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Orders

  def mount(%{"company_name" => _company_name, "role" => role}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company = Business.get_company!(user.company_id)
    company_name = company.name
    invoices = Orders.list_invoices(user.company_id, role)

    socket =
      assign(socket,
        invoices: invoices,
        role: role,
        company_name: company_name,
        user_is_admin: user.is_admin
      )

    {:ok, socket}
  end

  def handle_event("open-invoice", %{"invoice_id" => invoice_id}, socket) do
    {:noreply,
     socket
     |> redirect(
       to:
         ~p"/invoice_manager/#{socket.assigns.company_name}/browser/#{socket.assigns.role}/#{invoice_id}"
     )}
  end

  defp get_company_name(company_id), do: Business.get_company_name(company_id)

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
