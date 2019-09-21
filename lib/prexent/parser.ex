defmodule Prexent.Parser do
  @moduledoc """
  This module is the parser from markdown to HTML
  """
  require Logger

  @doc """
  Parses slides of the markdown to a list of HTML.
  If exists any parse error, the item in the list will be the error message.

  It recognizes some commands:

  * `!include <file>` - with a markdown file to include in any place
  * `!code <file>` - will parse a code script
  """
  @spec to_html_list(String.t()) :: List.t()
  def to_html_list(path_to_file) do
    try do
      read_file!(path_to_file)
      |> parse_content()
      # Quizá splittear antes y parsear de a chunks?
      |> String.split("---")
    catch
      :enoent -> ["# Markdown file not found!\n#{path_to_file}"]
      reason -> ["# Markdown file read failed!\n## Reason '#{inspect(reason)}'\n#{path_to_file}"]
    end
    |> Enum.map(fn slide ->
      case Earmark.as_html(slide) do
        {:ok, html_doc, _} ->
          html_doc

        {:error, _html_doc, error_messages} ->
          error_messages
      end
    end)
  end

  defp parse_content(content) do
    regex = ~r/^!([\S*]+) ([\S*]+).*$/m

    Regex.scan(regex, content)
    |> Enum.reduce(
      content,
      fn [line, command, argument], acc ->
        case process_command(command, argument) do
          {:replace, parsed} -> String.replace(acc, line, parsed)
          _ -> acc
        end
      end
    )
  end

  defp process_command("code", path_to_file) do
    content =
      try do
        file_content = read_file!(path_to_file)
        "```\n#{file_content}\n```"
      catch
        _ -> "Code file not found: #{path_to_file}"
      end

    {:replace, content}
  end

  defp process_command("include", path_to_file) do
    content =
      try do
        read_file!(path_to_file)
        |> parse_content()
      catch
        _ -> "Included file not found: #{path_to_file}"
      end

    {:replace, content}
  end

  defp process_command(_, _), do: nil

  defp read_file!(path_to_file) do
    abspath = Path.absname(path_to_file)

    case File.read(abspath) do
      {:ok, content} ->
        content

      {:error, reason} ->
        Logger.error("Couldn't read file with reason '#{inspect(reason)}'\n#{abspath}")
        throw(reason)
    end
  end
end
