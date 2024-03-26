defmodule InvoiceManagerWeb.Live.Show do
  use Phoenix.Component
  use Phoenix.HTML

  @moduledoc false

  def pagination(assigns) do
    ~H"""
    <div class={"flex #{if @pagination.page_num == 1, do: "justify-end", else: "justify-between"}"}>
      <button
        :if={@pagination.page_num != 1}
        phx-click="change-page"
        phx-value-direction="left"
        class="border border-blue-700 mt-2 bg-blue-500 text-white font-semibold px-3 py-1 rounded-full shadow-md hover:bg-blue-600 mr-2"
      >
        &lt;
      </button>
      <button
        :if={@pagination.page_num != @pagination.pages}
        phx-click="change-page"
        phx-value-direction="right"
        class="border border-blue-700 mt-2 bg-blue-500 text-white font-semibold px-3 py-1 rounded-full shadow-md hover:bg-blue-600"
      >
        &gt;
      </button>
    </div>
    <div class="flex justify-center">
      <%= @pagination.page_num %> / <%= @pagination.pages %>
    </div>
    """
  end

  def invoice_navigation(assigns) do
    ~H"""
    <div class="w-[250px] drop-shadow rounded absolute top-[15px] left-[30px]">
      <details class="bg-gray-300 open:bg-amber-200 duration-300">
        <summary class="bg-inherit px-5 py-3 font-semibold cursor-pointer">My invoices</summary>
        <div class="bg-white px-5 py-2 border border-gray-300 text-sm font-light">
          <ul class="">
            <li class="">
              <.link
                navigate="/invoice_manager/browser/incoming"
                class="leading-6 text-blue-900 font-semibold hover:text-blue-700"
              >
                Incoming
              </.link>
            </li>
            <li class="mt-1">
              <.link
                navigate="/invoice_manager/browser/outgoing"
                class="leading-6 text-blue-900 font-semibold hover:text-blue-700"
              >
                Outgoing
              </.link>
            </li>
          </ul>
        </div>
      </details>
      <details class="bg-gray-300 open:bg-amber-200 duration-300">
        <summary class="bg-inherit px-5 font-semibold cursor-pointer">Editor</summary>
        <div class="bg-white px-5 py-2 border border-gray-300 text-sm font-light">
          <.link
            navigate={"/invoice_manager/#{@company_name}/open_editor"}
            class="font-semibold leading-6 text-blue-900 hover:text-blue-700"
          >
            Select Invoice
          </.link>
        </div>
      </details>
      <details class="bg-gray-300 open:bg-amber-200 duration-300">
        <summary class="bg-inherit px-5 py-3 font-semibold cursor-pointer">My company</summary>
        <div class="bg-white px-5 py-2 border border-gray-300 text-sm font-light">
          <ul class="">
            <li class="">
              <.link
                navigate={"/invoice_manager/#{@company_name}/my_products"}
                class="leading-6 text-blue-900 font-semibold hover:text-blue-700"
              >
                Inventory
              </.link>
            </li>
            <li :if={@user_is_admin} class="mt-1">
              <.link
                navigate={"/invoice_manager/#{@company_name}/company_settings"}
                class="leading-6 text-blue-900 font-semibold hover:text-blue-700"
              >
                Settings
              </.link>
            </li>
            <li :if={@user_is_admin} class="mt-1">
              <.link
                navigate={"/invoice_manager/#{@company_name}/new_member"}
                class="leading-6 text-blue-900 font-semibold hover:text-blue-700"
              >
                New member
              </.link>
            </li>
          </ul>
        </div>
      </details>
    </div>
    """
  end
end
