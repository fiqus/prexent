defmodule Mix.Tasks.Prexent.New do
  @moduledoc """
  Creates a new Prexent project.

      $ mix prexent.new NAME

  This command will create the structure of a presentation, will prompt to the user to install dependencies and
  create an example `slides.md` source file.
  """
  use Mix.Task

  @doc false
  def run(argv) do
    check_input_file!(argv)
    elixir_version_check!()

    name = hd(argv)
    Mix.shell.info ":: #{name} prexent will be created ::"
    File.mkdir_p!(name)
    Mix.shell.info "* dir created"
    File.cd!(name)
    File.mkdir_p!("code")

    create_default_md!(name)
    Mix.shell.info "* default slide.md created"
    create_mix_exs_file!(name)
    Mix.shell.info "* mix.exs created"
    create_gitignore!()
    prompt_to_install_deps(name)
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

  defp hex_available? do
    Code.ensure_loaded?(Hex)
  end

  defp install_deps(install?) do
   if install? && hex_available?(), do: cmd("mix deps.get")
  end

  defp rebar_available? do
    Mix.Rebar.rebar_cmd(:rebar) && Mix.Rebar.rebar_cmd(:rebar3)
  end

  defp cmd(cmd) do
    Mix.shell.info [:green, "* running ", :reset, cmd]
    case Mix.shell.cmd(cmd, []) do
      0 ->
        []
      _ ->
        "$ #{cmd}"
    end
  end

  defp prompt_to_install_deps(path) do
    install? = Mix.shell.yes?("\nFetch and install dependencies?")
    Mix.shell.info "$ cd #{path}"

    mix_step = install_deps(install?)

    compile =
      case mix_step do
        [] -> Task.async(fn -> rebar_available?() && cmd("mix deps.compile") end)
        _  -> Task.async(fn -> :ok end)
      end

    Task.await(compile, :infinity)

    Mix.shell.info mix_step

    print_mix_run_info(path)
  end

  defp print_mix_run_info(path) do
    Mix.shell.info """
    Start your prexent with:
        $ cd #{path}
        $ mix prexent
    You can specify the source markdown file if you change the default:
        $ mix prexent SOURCE_FILE_PATH
    """
  end
end
