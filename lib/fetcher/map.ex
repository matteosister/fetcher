defmodule Fetcher.Map do
  @moduledoc """
  Fetcher implementation for the map type
  """

  import Enum

  @doc """
  Extracts data from a map. It returns a tuple with {:ok, params} if every requested
  key is present, and {:error, "the parameter '...' is missing"} for the first key not found.

  if `all` is true the function returns either {:ok, params}, or {:error, [error]} with all the keys that
  couldn't be found.

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
  def fetch(source, keys, all \\ false) do
    source
    |> do_fetch_params(keys, %{})
    |> handle_result(source, keys, all)
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
  defp handle_result({:error, _}, source, keys, true) do
    keys
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
