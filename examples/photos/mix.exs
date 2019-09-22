defmodule Photos.MixProject do
  use Mix.Project

  def project do
    [
      app: :photos,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
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
      {:prexent, "~> 0.1.1"}
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
