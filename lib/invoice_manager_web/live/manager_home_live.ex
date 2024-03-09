defmodule InvoiceManagerWeb.ManagerHomeLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])

    socket =
      socket
      |> assign(user_id: user.id)
      |> assign(user_is_admin: user.is_admin)
      |> assign(company_name: Business.get_company!(user.company_id).name)

    {:ok, socket}
  end
end
