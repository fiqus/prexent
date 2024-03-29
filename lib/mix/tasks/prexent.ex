defmodule Mix.Tasks.Prexent do
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
    Application.put_env(:prexent, :source_md, source_md)

    Application.put_env(:phoenix, :serve_endpoints, true, persistent: true)

    # maybe_put_port(args)
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

  # defp maybe_put_port(args) do
  #   flag_index = Enum.find_index(args, & &1 === "--port")
  #   if flag_index >= 0 && length(args) > flag_index do
  #     try do
  #       port =
  #         args
  #         |> Enum.at(flag_index + 1)
  #         |> String.to_integer()

  #       endpoint_config = Application.get_env(:prexent, PrexentWeb.Endpoint)
  #       endpoint_config = put_in(endpoint_config[:http][:port], port)
  #       Application.put_env(:prexent, PrexentWeb.Endpoint, endpoint_config)
  #     rescue
  #       _ -> Mix.raise "The port is invalid"
  #     end
  #   end
  # end
end
