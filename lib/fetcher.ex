defmodule Fetcher do
  @moduledoc """
  Public api of the library
  """

  @type options :: [all: boolean, fail_check: (any -> boolean)]
  @type selector :: [binary | atom]

  @doc """
  extracts the given `selector` from the `source`.

  Possible options:

  - all: (boolean) true to return all errored fields, false to return only the first one encountered.
  - fail_check: (a function that returns a boolean) tells fetcher how to consider not valid a field based on its value.
    Normally fetcher consider not valid only if the field is not present at all. While a null field is ok.

  Returns `{:ok, result}` or `{:error, error}`

  ## Examples

      iex> #{__MODULE__}.fetch(%{"a" => 1}, ["a"])
      {:ok, %{"a" => 1}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ["a"])
      {:ok, %{"a" => 1}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ["a", "b"])
      {:ok, %{"a" => 1, "b" => 2}}

      iex> #{__MODULE__}.fetch(%{"a" => 1, "b" => 2}, ["a", "b", "c"])
      {:error, "the field 'c' is missing"}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, [:a, :b])
      {:ok, %{a: 1, b: 2}}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, [:c, :d])
      {:error, "the field 'c' is missing"}

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, [:c, :d], all: true)
      {:error, ["the field 'c' is missing", "the field 'd' is missing"]}

      iex> #{__MODULE__}.fetch(%{a: 1, b: nil}, [:a, :b], fail_check: &is_nil/1)
      {:error, "the field 'b' is missing"}
  """
  @spec fetch(any, selector, options) :: {:ok, any} | {:error, binary|[binary]}
  def fetch(source, selector, options \\ []) when is_map(source) do
    Fetcher.Map.fetch(source, selector, options)
  end
end
