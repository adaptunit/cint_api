defmodule CintApi.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cint_api,
      version: "0.1.1",
      elixir: "~> 1.4",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      applications: [:logger_file_backend],
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:hackney, "~> 1.6"},
      {:httpoison, "~> 0.9.2"},
      {:poison, "~> 2.0"},
      {:uuid, "~> 1.1"},
      {:phoenix_ecto, "~> 3.0"},
      {:earmark, ">= 0.0.0", only: :dev},
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:logger_file_backend, "~> 0.0.10"},
    ]
  end
end
