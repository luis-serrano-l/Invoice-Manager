defmodule InvoiceManager.Utils do
  @moduledoc """
  Common functions for liveviews.
  """

  alias InvoiceManager.Business

  @spec to_euro(float() | 0) :: String.t()
  def to_euro(0), do: "0.00 €"
  def to_euro(number), do: :erlang.float_to_binary(number, decimals: 2) <> " €"

  @spec change_map(map(), map()) :: map()
  def change_map(old_map, new_map) do
    Map.merge(old_map, new_map, fn _k, _v1, v2 -> v2 end)
  end

  @spec paginate(integer(), non_neg_integer(), integer(), integer()) :: %{
          pages: integer(),
          offset: non_neg_integer(),
          page_num: integer()
        }
  def paginate(pages, offset, page_num, move) do
    %{pages: pages, offset: offset, page_num: page_num + move}
  end

  @spec get_costs(list(struct()), float(), float()) :: %{
          discount: float(),
          tax_rate: float(),
          taxes: float(),
          total: float(),
          value: float()
        }
  def get_costs(items, tax_rate, discount) do
    value = calculate_value(items)

    taxes =
      (value * tax_rate / 100)
      |> Float.round(2)

    total =
      (value + taxes - discount)
      |> Float.round(2)

    %{value: value, taxes: taxes, total: total, tax_rate: tax_rate, discount: discount}
  end

  @spec calculate_value(list(struct())) :: float() | 0
  defp calculate_value([]), do: 0

  defp calculate_value(items) do
    items
    |> Enum.reduce(0, fn item, acc ->
      item.quantity *
        item.price +
        acc
    end)
    |> Float.round(2)
  end

  def get_company_name(id), do: Business.get_company_name(id)
end
