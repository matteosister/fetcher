defmodule Fetcher.Map do
  @moduledoc """
  Fetcher implementation for the map type
  """
  import Enum
  @type result :: {:ok, map} | {:error, binary | [binary]}

  @doc """
  Extracts data from a map. It returns a tuple with {:ok, params} if every requested
  key is present, and {:error, "the parameter '...' is missing"} for the first key not found.

  if `all` is true the function returns either {:ok, params}, or {:error, [error]} with all the keys that
  couldn't be found.
  """
  @spec fetch(map, [any], Fetcher.options) :: result
  def fetch(source, keys, options) do
    source
    |> do_fetch_params(keys, %{}, options)
    |> handle_result(source, keys, options)
  end

  @spec do_fetch_params(map, [term], map, Fetcher.options) :: map
  defp do_fetch_params(_params, [], acc, _options), do: acc
  defp do_fetch_params(source, [field_name | other_fields_names], acc, options) do
    with {:ok, value} <- fetch_param(source, field_name, options) do
      do_fetch_params(source, other_fields_names, Map.put(acc, field_name, value), options)
    end
  end

  @spec fetch_param(map, binary, Fetcher.options) :: result
  defp fetch_param(source, field_name, options) do
    with {:ok, value} <- Map.fetch(source, field_name),
         :ok <- discard_check(value, options) do
      {:ok, value}
    else
      :error -> {:error, error_message(field_name)}
    end
  end

  @spec handle_result(result, map, [any], Fetcher.options) :: result
  defp handle_result({:error, _} = error, source, keys, options) do
    if get_option(options, :all, false) do
      keys
      |> reduce([], fn field_name, acc ->
        case fetch_param(source, field_name, options) do
          {:ok, _} -> acc
          {:error, error} -> [error | acc]
        end
      end)
      |> fn errors -> {:error, reverse errors} end.()
    else
      error
    end
  end
  defp handle_result(result, _source, _required_params, _options) do
    {:ok, result}
  end

  @spec error_message(binary) :: binary
  defp error_message(field_name), do: "the field '#{field_name}' is missing"

  @spec discard_check(any, Fetcher.options) :: :ok | :error
  defp discard_check(value, options) do
    options
    |> get_option(:fail_check, fn _ -> false end)
    |> Kernel.apply([value])
    |> if(do: :error, else: :ok)
  end

  @spec get_option(Fetcher.options, atom, any) :: any
  defp get_option(options, name, default), do: Keyword.get(options, name, default)
end
