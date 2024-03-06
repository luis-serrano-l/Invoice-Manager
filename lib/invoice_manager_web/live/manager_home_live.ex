defmodule InvoiceManagerWeb.ManagerHomeLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_name = Business.get_company!(user.company_id).name
    user_is_admin = user.is_admin
    Process.send_after(self(), :clear_flash, 1200)

    socket =
      socket
      |> assign(user_id: user.id)
      |> assign(user_is_admin: user_is_admin)
      |> assign(company_name: company_name)

    {:ok, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
