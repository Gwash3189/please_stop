defmodule PleaseStop.Mixfile do
  use Mix.Project

  def project do
    [
      app: :please_stop,
      name: "PleaseStop",
      version: "1.0.0",
      elixir: "~> 1.6",
      description: "Rate limiting plug for Cowboy / Phoenix",
      package: %{
        maintainers: ["Adam Beck"],
        licenses: ["MIT"],
        links: %{
          Github: "https://github.com/Gwash3189/please_stop"
        }
      },
      source_url: "https://github.com/Gwash3189/please_stop",
      homepage_url: "https://github.com/Gwash3189/please_stop",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        main: "PleaseStop",
        extras: ["README.md"]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PleaseStop.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug, "~> 1.4"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:con_cache, "~> 0.12.1"},
      {:poolboy, "~> 1.5"},
      {:ex_doc, "~> 0.14", only: :dev}
    ]
  end
end
