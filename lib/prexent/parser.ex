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
    case File.read(path_to_file) do
      {:ok, content} ->
        content
        |> parse_content()
        |> String.split("---")

      {:error, reason} ->
        Logger.error("The markdown file couldn't be read, reason: #{inspect(reason)}")
        []
    end
    |> Enum.map(
         fn slide ->
           case Earmark.as_html(slide) do
             {:ok, html_doc, _} ->
               html_doc

             {:error, _html_doc, error_messages} ->
               error_messages
           end
         end
       )
  end

  defp parse_content(content) do
    regex = ~r/^!([\S*]+) ([\S*]+).*$/m
    Regex.scan(regex, content)
    |> Enum.reduce(
         content,
         fn [line, command, argument], acc ->
           process_command(acc, line, command, argument)
         end
       )
  end

  defp process_command(content, line, "code", argument) do
    case File.read(Path.absname(argument)) do
      {:ok, file_content} ->
        IO.inspect(file_content)
        String.replace(content, line, "```\n#{file_content}\n```")
      {:error, reason} ->
        Logger.error("The markdown file couldn't be read, reason: #{inspect(reason)}")
        String.replace(content, line, "")
    end
  end

  defp process_command(content, line, "include", argument) do
    case File.read(Path.absname(argument)) do
      {:ok, included_content} ->
        String.replace(content, line, parse_content(included_content))

      {:error, reason} ->
        Logger.error("The markdown file couldn't be read, reason: #{inspect(reason)}")
        String.replace(content, line, "")
    end
  end

  defp process_command(content, _, _, _), do: content
end
