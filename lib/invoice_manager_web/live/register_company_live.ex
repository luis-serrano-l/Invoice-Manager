defmodule InvoiceManagerWeb.RegisterCompanyLive do
  alias InvoiceManager.Business
  alias InvoiceManager.Business.Company
  alias InvoiceManager.Accounts
  use InvoiceManagerWeb, :live_view

  def mount(_params, session, socket) do
    user_id = Accounts.get_user_by_session_token(session["user_token"]).id
    contact_email = Accounts.get_user!(user_id).email
    company_changeset = Business.change_company(%Company{}, %{"contact_email" => contact_email})

    socket =
      socket
      |> assign(user_id: user_id)
      |> assign(:form, to_form(company_changeset))

    {:ok, socket}
  end

  def handle_event("validate", %{"company" => params}, socket) do
    form =
      %Company{}
      |> Business.change_company(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"company" => company_params}, socket) do
    case Business.create_company(company_params) do
      {:ok, company} ->
        Process.send_after(self(), :clear_flash, 1200)

        Accounts.update_user(Accounts.get_user!(socket.assigns.user_id), %{
          "company_id" => company.id,
          "is_admin" => true
        })
        |> IO.inspect(label: "UPDATED USER")

        {:noreply,
         socket
         |> put_flash(:info, "company created")
         |> redirect(to: ~p"/invoice_manager/#{company.name}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
