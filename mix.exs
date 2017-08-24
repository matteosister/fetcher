defmodule Fetcher.Mixfile do
  use Mix.Project

  def project do
    [
      app: :fetcher,
      version: "0.3.0",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end

  defp description do
    "Fetcher allows to fetch list of data from data structures and getting back meaningful errors"
  end

  defp package do
    %{maintainers: ["Matteo Giachino"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/matteosister/fetcher"}}
  end
end
