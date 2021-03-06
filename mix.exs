defmodule Shove.Mixfile do
  use Mix.Project

  def project() do
    [app: :shove,
     version: "0.0.1",
     elixir: "~> 1.1",
     description: description(),
     package: package(),
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application() do
    [applications: [:logger],
     mod: {Shove, []}]
  end

  defp deps() do
    [
      {:jason, "~> 1.2"},
      {:poolboy, "~> 1.5.1"}
    ]
  end

  defp description() do
    """
    Push notifications for Elixir
    """
  end

  defp package() do
    [
      maintainers: ["Cody Russell"],
      licenses: ["MIT"],
      links: %{github: "https://github.com/bratsche/shove"},
      files: ~w(mix.exs README.md lib config test LICENSE)
    ]
  end
end
