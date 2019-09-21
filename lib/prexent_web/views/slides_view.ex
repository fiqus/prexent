defmodule PrexentWeb.SlidesView do
  use PrexentWeb, :view

  def parse_slide(slide_index, %{type: :code, lang: lang, content: content}) do
    "<div class='code'>
      <pre><code class='#{lang}'>#{content}</code></pre>
      <button phx-click='run' phx-value-id='#{slide_index}'>Run</button>
    </div>"
  end

  def parse_slide(slide_index, %{type: :error, content: content}) do
    "<div class=\"error\">#{content}</div>"
  end

  def parse_slide(slide_index, %{content: content}) do
    content
  end
end
