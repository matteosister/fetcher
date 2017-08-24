defmodule FetcherTest do
  use ExUnit.Case, async: true
  doctest Fetcher

  defmodule FetcherTest.Data do
    defstruct [:a, :b, :c]

    def new(a, b, c), do: %__MODULE__{a: a, b: b, c: c}
  end

  test "fetch one field from a struct" do
    assert {:ok, %{a: "a"}} === Fetcher.fetch(FetcherTest.Data.new("a", "b", "c"), ~w(a)a)
  end

  test "fetch multiple field from a struct" do
    assert {:ok, %{a: "a", b: "b"}} === Fetcher.fetch(FetcherTest.Data.new("a", "b", "c"), ~w(a b)a)
  end

  test "fetch not existent field from a struct" do
    assert {:error, "the field 'd' is missing"} === Fetcher.fetch(FetcherTest.Data.new("a", "b", "c"), ~w(d)a)
  end
end
