defmodule InvoiceManagerWeb.BrowserLive do
  use InvoiceManagerWeb, :live_view
  import InvoiceManager.Utils

  alias InvoiceManager.Accounts
  alias InvoiceManager.Orders

  @size 5

  def mount(%{"role" => role}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company_id = user.company_id

    socket =
      assign(socket,
        invoices: Orders.list_invoices(company_id, @size, 0, role),
        user: user,
        role: role,
        company_name: get_company_name(company_id),
        pagination: new_paginate(company_id, @size, role)
      )

    {:ok, socket}
  end

  def handle_event("change-page", %{"direction" => direction}, socket) do
    pagination = socket.assigns.pagination
    company_id = socket.assigns.user.company_id
    role = socket.assigns.role

    case {{pagination.page_num, pagination.pages}, direction} do
      {{last, last}, "right"} ->
        {:noreply, put_flash(socket, :error, "Reached last page")}

      {{1, _}, "left"} ->
        {:noreply, put_flash(socket, :error, "Already first page")}

      {_, "right"} ->
        {:noreply, assign(socket, change_page(company_id, pagination, 1, @size, role))}

      {_, "left"} ->
        {:noreply, assign(socket, change_page(company_id, pagination, -1, @size, role))}
    end
  end

  def handle_event("open-invoice", %{"invoice_id" => invoice_id}, socket) do
    {:noreply,
     socket
     |> redirect(to: ~p"/invoice_manager/browser/#{socket.assigns.role}/#{invoice_id}")}
  end
end
