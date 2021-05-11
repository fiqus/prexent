defmodule Mix.Tasks.Prexent.Export do
  @moduledoc """
  Run the Phoenix server with the endpoints defined by Prexent.

  Execute `mix prexent` in your prexent project.

  The default markdown file is `slides.md`, if you want to use another source file, run:

      $ mix prexent FILE_NAME

  The source markdown file is set in `Application.put_env(:prexent, :source_md, source_md)` to be consumed by the live view endpoint.

  The default port is 4000, you can change it passing the `PORT` env:

      $ PORT=4040 mix prexent

  """
  use Mix.Task

  @doc false
  def run(args) do
    source_md = get_source_name(args)
    check_file!(source_md)
    Mix.shell.info "Exporting to static presentation at 'exported/'.."
    File.mkdir_p!("exported")
    html = generate(source_md)
    File.cd!("exported")
    File.write!("index.html", html)
    # copy static files
    File.copy!("../priv/static/js/app.js", "app.js")
    File.copy!("../priv/static/css/app.css", "app.css")
  end

  def generate(source_md) do
    slides = Prexent.Parser.to_parsed_list(source_md)

    assigns = %{
      layout: {PrexentWeb.LayoutView, "export.html"},
      slides: slides,
      slide: 0,
      code_runners: %{},
      pid_slides: %{}
    }

    Phoenix.View.render_to_string(PrexentWeb.SlidesView, "slides.html", assigns)
  end

  defp get_source_name([]), do: "slides.md"
  defp get_source_name(args), do: hd(args)

  defp check_file!(filename) do
    if not File.exists?(filename),
      do: Mix.raise("The slides source file '#{filename}' does not exist")
  end
end
