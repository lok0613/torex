defmodule Torex.MixProject do
  use Mix.Project

  def project do
    [
      app: :torex,
      version: "0.1.0",
      elixir: "~> 1.11.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Elixir connector to Tor network",
      package: package()
    ]
  end

  defp package do
    [
      maintainers: ["Alex Filatov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/alexfilatov/torex"}
    ]
  end

  # Configuration for the OTP application
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger], mod: {Torex, []}]
  end

  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false}
    ]
  end
end
