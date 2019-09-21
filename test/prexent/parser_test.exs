defmodule Prexent.ParserTest do
  use ExUnit.Case, async: true

  test "parses the input.md file" do
    html_list = Prexent.Parser.to_html_list("test/prexent/input.md")

    assert html_list == [
             "<h1>Title</h1>\n<ul>\n<li>Point 1\n</li>\n<li>Point 2\n</li>\n</ul>\n",
             "<h2>Second slide</h2>\n<blockquote><p>Best quote ever.</p>\n</blockquote>\n<p>Note: speaker notes FTW!</p>\n",
             "<h1>Nice function</h1>\n<p>that really works!</p>\n<p>Code file not found: myfun.exs</p>\n",
             "<p>Another useful function:</p>\n<p>Code file not found: afun.exs</p>\n"
           ]
  end
end
