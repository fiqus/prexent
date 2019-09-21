defmodule PrexentWeb.SlidesView do
  use PrexentWeb, :view

  def parse_slide(%{type: :code, lang: lang, content: content}) do
    "<pre><code class=\"#{lang}\">#{content}</code></pre>"
  end

  def parse_slide(%{type: :error, content: content}) do
    "<div class=\"error\">#{content}</div>"
  end

  def parse_slide(%{content: content}) do
    content
  end
end
