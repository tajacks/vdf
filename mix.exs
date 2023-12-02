defmodule Vdf.MixProject do
  use Mix.Project

  def project do
    [
      app: :vdf,
      description: "Utilities for working with Valve's VDF file format",
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        ignore_warnings: ".dialyzer_ignore.exs",
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: [:error_handling, :unknown],
        # Error out when an ignore rule is no longer useful so we can remove it
        list_unused_filters: true
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.30.6", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18.0", only: :test},
      {:dialyxir, "~> 1.4.1", only: [:dev, :test], runtime: false}
    ]
  end

  defp package do
    [
      name: "vdf",
      licenses: ["LGPL-3.0-only"],
      links: %{"GitHub" => "https://github.com/tajacks/vdf"}
    ]
  end
end
