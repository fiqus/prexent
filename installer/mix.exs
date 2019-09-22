defmodule Prexent.New.MixProject do
  use Mix.Project

  @version "0.1.0"
  @github_path "spawnfest/prexent"
  @url "https://github.com/#{@github_path}"

  def project do
    [
      app: :prexent_new,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: [
          "Pablo Brudnick",
          "Diego Calero",
          "Mariano Lambir",
          "Joaquín Mansilla"
        ],
        licenses: ["MIT"],
        links: %{github: @url},
        files: ~w(lib mix.exs README.md)
      ],
      source_url: @url,
      docs: docs(),
      description: "Prexent installer"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      source_url_pattern: "https://github.com/#{@github_path}/blob/v#{@version}/installer/%{path}#L%{line}"
    ]
  end
end
