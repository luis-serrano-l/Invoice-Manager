defmodule InvoiceManager.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `InvoiceManager.Accounts` context.
  """

  @doc """
  Generate a user_and_company.
  """
  def user_and_company_fixture(attrs \\ %{}) do
    {:ok, user_and_company} =
      attrs
      |> Enum.into(%{
        admin: true
      })
      |> InvoiceManager.Accounts.create_user_and_company()

    user_and_company
  end

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> InvoiceManager.Accounts.register_user()

    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
