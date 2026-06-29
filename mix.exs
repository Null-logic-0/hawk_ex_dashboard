defmodule HawkExDashboard.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/Null-logic-0/hawk_ex_dashboard"

  def project do
    [
      app: :hawk_ex_dashboard,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      docs: docs(),
      aliases: aliases(),
      compilers: Mix.compilers(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() == :dev do
      [
        mod: {HawkExDev.App, []},
        extra_applications: [:logger]
      ]
    else
      [extra_applications: [:logger]]
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hawk_ex, path: "../hawk_ex"},
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.2"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_template, "~> 1.0", override: true},

      # Dev only — the harness app
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.4"},
      {:bandit, "~> 1.0", only: :dev},

      # Dev/Test only
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      dev: "run --no-halt",
      "dev.setup": ["dev.create", "dev.migrate"],
      "dev.create": "ecto.create --repo HawkExDev.Repo",
      "dev.migrate": "ecto.migrate --repo HawkExDev.Repo --migrations-path dev/migrations"
    ]
  end

  defp package do
    [
      name: :hawk_ex_dashboard,
      version: @version,
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      source_url: @source_url,
      docs: docs(),
      files: ~w(lib priv mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "HawkExDashboard",
      source_url: @source_url,
      source_ref: @version
    ]
  end

  defp description do
    "LiveView dashboard for HAWK_EX — billing, audit, and CSV monitoring"
  end

  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(_), do: ["lib"]
end
