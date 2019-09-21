defmodule PrexentWeb.SlidesView do
  use PrexentWeb, :view

  def parse_slide(slide_idx, content_idx, %{type: :code, lang: lang, content: content}) do
    "<div class='code'>
      <pre><code class='#{lang}'>#{content}</code></pre>
      <button phx-click='run' phx-value-slide_idx='#{slide_idx}' phx-value-content_idx='#{content_idx}'>Run</button>
    </div>"
  end

  def parse_slide(_lide_idx, _content_idx, %{type: :error, content: content}) do
    "<div class=\"error\">#{content}</div>"
  end

  def parse_slide(_slide_idx, _content_idx, %{content: content}) do
    content
  end
end
