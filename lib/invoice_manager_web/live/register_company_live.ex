defmodule InvoiceManagerWeb.RegisterCompanyLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Business
  alias InvoiceManager.Business.Company

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

  def render(assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:address]} type="text" label="Address" required />
      <.input field={@form[:contact_email]} type="text" label="Contact Email" required />
      <.input field={@form[:contact_phone]} type="text" label="Contact Phone" required />
      <.input field={@form[:fiscal_number]} type="text" label="Fiscal Number" required />
      <.input field={@form[:name]} type="text" label="Name" required />
      <:actions>
        <.button id="submit" phx-disable-with="Saving...">Save</.button>
      </:actions>
    </.simple_form>
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
    case Business.create_company(company_params) do
      {:ok, company} ->
        Accounts.update_user(Accounts.get_user!(socket.assigns.user_id), %{
          "company_id" => company.id,
          "is_admin" => true
        })

        {:noreply,
         socket
         |> put_flash(:info, "company created")
         |> redirect(to: ~p"/invoice_manager/#{company.name}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
