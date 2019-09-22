defmodule Mix.Tasks.Prexent do
  use Mix.Task

  @doc false
  def run(args) do
    source_md = get_source_name(args)
    check_file!(source_md)
    Application.put_env(:prexent, :source_md, source_md)

    Application.put_env(:phoenix, :serve_endpoints, true, persistent: true)

    Mix.Tasks.Run.run(run_args())
  end

  defp get_source_name([]), do: "slides.md"
  defp get_source_name(args), do: hd(args)

  defp run_args do
    if iex_running?(), do: [], else: ["--no-halt"]
  end

  defp iex_running? do
    Code.ensure_loaded?(IEx) and IEx.started?()
  end

  defp check_file!(filename) do
    if not File.exists?(filename),
      do: Mix.raise("The slides source file '#{filename}' does not exist")
  end
end
