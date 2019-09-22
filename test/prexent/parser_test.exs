defmodule Prexent.ParserTest do
  use ExUnit.Case, async: true

  test "parses the input.md file" do
    html_list = Prexent.Parser.to_parsed_list("test/prexent/input.md")

    assert html_list == [
             [
               %{content: "test/prexent/background.jpg", type: :background},
               %{type: :html, content: ""},
               %{content: "Header", type: :header},
               %{content: "", type: :html},
               %{content: "Footer", type: :footer},
               %{
                 content: "<h1>Title</h1>\n<ul>\n<li>Point 1\n</li>\n<li>Point 2\n</li>\n</ul>\n",
                 type: :html
               }
             ],
             [
               %{
                 content:
                   "<h2>Second slide</h2>\n<blockquote><p>Best quote ever.</p>\n</blockquote>\n<p>Note: speaker notes FTW!</p>\n",
                 type: :html
               }
             ],
             [
               %{content: "", type: :html},
               %{content: "<h1>Nice function</h1>\n<p>that really works!</p>\n", type: :html},
               %{content: "Code file not found: myfun.exs", type: :error},
               %{content: "", type: :html},
               %{content: "<p>Another useful function:</p>\n", type: :html},
               %{content: "Code file not found: afun.exs", type: :error}
             ]
           ]
  end
end
