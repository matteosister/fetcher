defmodule Fetcher do
  @moduledoc """
  Public api of the library
  """

  @type options :: [all :: boolean]
  @type selector :: [binary | atom]

  @doc """
  extracts the given `selector` from the `source`.

  Have a look at the type `options` for possible options

  Always returns `{:ok, result}` or `{:error, error}`

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

      iex> #{__MODULE__}.fetch(%{a: 1, b: 2}, ~w[c d]a, all: true)
      {:error, ["the field 'c' is missing", "the field 'd' is missing"]}
  """
  @spec fetch(any, selector, options) :: {:ok, any} | {:error, binary|[binary]}
  def fetch(source, selector, options \\ []) when is_map(source) do
    Fetcher.Map.fetch(source, selector, Keyword.get(options, :all, false))
  end
end
