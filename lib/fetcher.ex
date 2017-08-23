defmodule Fetcher do
  @moduledoc """
  Main Fetcher module
  """
  def fetch(source, selector) when is_map(source), do: Fetcher.Map.fetch(source, selector)
end
