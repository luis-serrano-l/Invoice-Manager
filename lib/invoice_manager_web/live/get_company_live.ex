defmodule InvoiceManagerWeb.GetCompanyLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Accounts

  use InvoiceManagerWeb, :live_view

  def mount(_params, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id

    company_names =
      user_id
      |> Business.list_company_ids_by_user_id()
      |> Business.list_company_names_by_ids()

    if company_names do
      # probably better redirect as in user_settings_live.ex
      {:ok,
       socket
       |> redirect(to: ~p"/invoice_manager/#{hd(company_names)}")}
    else
      {:ok, socket}
    end
  end
end
