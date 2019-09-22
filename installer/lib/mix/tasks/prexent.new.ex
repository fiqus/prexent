defmodule Mix.Tasks.Prexent.New do
  @moduledoc """
  Creates a new Prexent project.

  `mix prexent.new NAME`
  """
  use Mix.Task

  def run(argv) do
    check_input_file!(argv)
    elixir_version_check!()

    name = hd(argv)
    File.mkdir_p!(name)
    File.cd!(name)
    File.mkdir_p!("code")

    create_default_md!(name)
    create_mix_exs_file!(name)
    create_gitignore!()
  end

  defp create_default_md!(name) do
    content = """
      # Welcome to #{name}!

      ---

      # This is the second slide

      Use "---" to create new slides :)
      """
    File.write!("slides.md", content)
  end

  defp create_gitignore!() do
    content = """
      # The directory Mix will write compiled artifacts to.
      /_build/
      """
    File.write!(".gitignore", content)
  end

  defp create_mix_exs_file!(name) do
    module = String.capitalize(name)
    app_name = String.downcase(name)

    content =
      """
      defmodule #{module}.MixProject do
        use Mix.Project

        def project do
          [
            app: :#{app_name},
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
            {:prexent, git: "https://github.com/spawnfest/prexent.git", branch: "master"}
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
      """

    File.write!("mix.exs", content)
  end

  defp check_input_file!([_name]), do: :ok
  defp check_input_file!(_) do
    Mix.raise "Prexent requires a name for your project.\n " <>
    "Try running: mix prexent.new YOUR_PROJECT"
  end

  defp elixir_version_check!() do
    unless Version.match?(System.version, "~> 1.5") do
      Mix.raise "Prexent requires at least Elixir v1.5.\n " <>
                "You have #{System.version()}. Please update accordingly"
    end
  end
end
