defmodule InvoiceManagerWeb.NewMemberLive do
  use InvoiceManagerWeb, :live_view

  alias InvoiceManager.Accounts
  alias InvoiceManager.Accounts.User
  alias InvoiceManager.Business

  def mount(%{"company_name" => _company_name}, session, socket) do
    user = Accounts.get_user_by_session_token(session["user_token"])
    user_is_admin = user.is_admin
    company_name = Business.get_company!(user.company_id).name
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok,
     assign(socket, company_name: company_name, user_is_admin: user_is_admin)
     |> assign(is_admin: false), temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    user_params = Map.put(user_params, "is_admin", socket.assigns.is_admin)

    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        company = Business.get_company_by_name(socket.assigns.company_name)
        Accounts.update_user(user, %{"company_id" => company.id})

        changeset = Accounts.change_user_registration(user)

        {:noreply,
         socket
         |> assign(trigger_submit: true)
         |> assign_form(changeset)
         |> put_flash(:info, "New member saved")
         |> redirect(to: ~p"/invoice_manager/#{socket.assigns.company_name}")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("select-is-admin", %{"is_admin" => "true"}, socket) do
    {:noreply, socket |> assign(is_admin: true)}
  end

  def handle_event("select-is-admin", %{"is_admin" => "false"}, socket) do
    {:noreply, socket |> assign(is_admin: false)}
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")

    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
