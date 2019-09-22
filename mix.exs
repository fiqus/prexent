defmodule Prexent.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_path "spawnfest/prexent"
  @url "https://github.com/#{@github_path}"

  def project do
    [
      app: :prexent,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        install: :prod
      ],
      package: [
        maintainers: [
          "Pablo Brudnick",
          "Diego Calero",
          "Mariano Lambir",
          "Joaquín Mansilla"
        ],
        licenses: ["MIT"],
        links: %{github: @url},
        files: ~w(lib priv mix.exs README.md)
      ],
      source_url: @url,
      docs: docs(),
      description: "Fast, live and beautiful presentations from Markdown powered by Phoenix LiveView"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Prexent.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:phoenix_live_view, "~> 0.3.0"},
      {:earmark, "~> 1.4"},
      {:exexec, "~> 0.2"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      install: ["do archive.build, archive.install"]
    ]
  end

  defp docs do
    [
      source_url_pattern: "https://github.com/#{@github_path}/blob/v#{@version}/%{path}#L%{line}"
    ]
  end
end
