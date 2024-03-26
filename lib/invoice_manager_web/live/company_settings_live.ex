defmodule InvoiceManagerWeb.CompanySettingsLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Business.Company

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    company = Business.get_company!(user.company_id)
    company_changeset = Business.change_company(company)

    {:ok,
     socket
     |> assign(form: to_form(company_changeset))
     |> assign(company_id: company.id)
     |> assign(company_name: company.name)
     |> assign(user_is_admin: user.is_admin)}
  end

  def render(assigns) do
    ~H"""
    <div class="flex">
      <InvoiceManagerWeb.Live.Show.invoice_navigation
        company_name={@company_name}
        user_is_admin={@user_is_admin}
      />
      <div class="flex-grow mx-auto max-w-sm">
        <.simple_form for={@form} phx-change="validate" phx-submit="save">
          <.input field={@form[:address]} type="text" label="Address" required />
          <.input field={@form[:contact_email]} type="text" label="Contact Email" required />
          <.input field={@form[:contact_phone]} type="text" label="Contact Phone" required />
          <.input field={@form[:fiscal_number]} type="text" label="Fiscal Number" required />
          <:actions>
            <.button id="submit" phx-disable-with="Saving...">Save</.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
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
    company = Business.get_company!(socket.assigns.company_id)

    case Business.update_company(company, company_params) do
      {:ok, company} ->
        company_changeset = Business.change_company(company)

        {:noreply,
         socket
         |> assign(form: to_form(company_changeset))
         |> put_flash(:info, "Company settings updated succesfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end
end
