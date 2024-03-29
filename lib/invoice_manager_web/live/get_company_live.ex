defmodule InvoiceManagerWeb.GetCompanyLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business

  def mount(_params, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    case user.company_id do
      nil ->
        {:ok, socket}

      company_id ->
        company_name = Business.get_company_name(company_id)
        # probably better redirect as in user_settings_live.ex
        {:ok,
         socket
         |> redirect(to: ~p"/invoice_manager/#{company_name}")}
    end
  end
end
