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

  def render(assigns) do
    ~H"""
    <div class="flex">
      <InvoiceManagerWeb.Live.Show.invoice_navigation
        company_name={@company_name}
        user_is_admin={@user_is_admin}
      />
      <div class="flex-grow mx-auto max-w-sm">
        <.header class="text-center text-lg font-semibold">
          <h2>
            Add a new member to your company
          </h2>
        </.header>

        <.simple_form for={@form} id="registration_form" phx-submit="save" phx-change="validate">
          <.error :if={@check_errors}>
            Oops, something went wrong! Please check the errors below.
          </.error>

          <.input field={@form[:email]} type="email" label="Email" required />
          <.input field={@form[:password]} type="password" label="Password" required />
          <.input field={@form[:name]} type="text" label="Name" required />
          <.input field={@form[:last_name]} type="text" label="Last name" required />

          <.label for="is_admin">Admin</.label>
          <select
            name="is_admin"
            id="is_admin"
            class="w-full  svelte-1l8159u mt-1 block w-full rounded-lg text-zinc-900 focus:ring-0 sm:text-sm sm:leading-6 phx-no-feedback:border-zinc-300 phx-no-feedback:focus:border-zinc-400 border-zinc-300 focus:border-zinc-400"
          >
            <option value="false" phx-value-is_admin="false" phx-click="select-is-admin">No</option>
            <option value="true" phx-value-is_admin="true" phx-click="select-is-admin">Yes</option>
          </select>

          <:actions>
            <.button phx-disable-with="Registering..." class="w-full">
              Register
            </.button>
          </:actions>
        </.simple_form>
      </div>
    </div>
    """
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
