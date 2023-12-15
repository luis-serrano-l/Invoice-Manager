defmodule InvoiceManagerWeb.ManagerHomeLive do
  alias InvoiceManager.Accounts
  use InvoiceManagerWeb, :live_view

  def mount(%{"company_name" => company_name}, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id

    Process.send_after(self(), :clear_flash, 1200)

    socket =
      socket
      |> assign(user_id: user_id)
      |> assign(company_name: company_name)

    {:ok, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
