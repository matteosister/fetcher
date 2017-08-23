defmodule Fetcher.Map do
  @moduledoc """
  utility to extract data from a map, giving contextual errors
  """
  import Enum

  @doc """
  this method extracts the requested data from a map. It gives you back a tuple with {:ok, params} if every requested
  parameter is present, while returns {:error, "the parameter '...' is missing"} when the first of the given parameter
  couldn't be found.

  The third boolean parameter could be true if you want to traverse all tha map and getting back all errors

  ## Examples

      iex> #{__MODULE__}.fetch(%{"a" => 1}, ~w[a])
      {:ok, %{"a" => 1}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ~w[a])
      {:ok, %{"a" => 1}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ~w[a b])
      {:ok, %{"a" => 1, "b" => 2}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ~w[a b c])
      {:error, "the field 'c' is missing"}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, ~w[a b]a)
      {:ok, %{a: 1, b: 2}}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, ~w[c d]a)
      {:error, "the field 'c' is missing"}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, ~w[c d]a, true)
      {:error, ["the field 'c' is missing", "the field 'd' is missing"]}
  """
  @spec fetch(map, [binary], boolean) :: {:ok, map} | {:error, binary}
  def fetch(source, required_params, all \\ false) do
    source
    |> do_fetch_params(required_params, %{})
    |> handle_result(source, required_params, all)
  end

  @spec do_fetch_params(map, [term], map) :: map
  defp do_fetch_params(_params, [], acc), do: acc
  defp do_fetch_params(source, [field_name | other_fields_names], acc) do
    with {:ok, value} <- fetch_param(source, field_name) do
      do_fetch_params(source, other_fields_names, Map.put(acc, field_name, value))
    end
  end

  @spec fetch_param(map, binary) :: {:ok, any} | {:error, binary}
  defp fetch_param(source, field_name) do
    case Map.get(source, field_name) do
      nil -> {:error, error_message(field_name)}
      v   -> {:ok, v}
    end
  end

  defp handle_result({:error, _} = error, _source, _required_params, false), do: error
  defp handle_result({:error, _}, source, required_params, true) do
    required_params
    |> reduce([], fn field_name, acc ->
      case fetch_param(source, field_name) do
        {:ok, _} -> acc
        {:error, error} -> [error | acc]
      end
    end)
    |> fn errors -> {:error, reverse errors} end.()
  end
  defp handle_result(result, _source, _required_params, _all) do
    {:ok, result}
  end

  defp error_message(field_name), do: "the field '#{field_name}' is missing"
end
