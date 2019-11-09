defmodule FeatureShowcase.MixProject do
  use Mix.Project

  def project do
    [
      app: :feature_showcase,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      preferred_cli_env: [prexent: :prod],
      config_path: config_path()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:prexent, "~> 0.2"}
    ]
  end

  defp config_path do
    prexent_config = "deps/prexent/config/config.exs"
    if File.exists?(prexent_config) do
      prexent_config
    else
      "config/config.exs"
    end
  end
end
