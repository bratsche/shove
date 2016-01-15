defmodule Shove.Mixfile do
  use Mix.Project

  def project do
    [app: :shove,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger],
     mod: {Shove, []}]
  end

  defp deps do
    [
      {:poison, "~> 1.5"},
      {:poolboy, "~> 1.5.1"}
    ]
  end

  defp description do
    """
    Push notifications for Elixir
    """
  end

  defp package do
    [
      maintainers: ["Cody Russell"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/bratsche/shove"},
      files: ~w(mix.exs README.md lib config test LICENSE)
    ]
  end
end
