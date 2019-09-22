defmodule PrexentWeb.SlidesView do
  use PrexentWeb, :view

  def parse_slide(slide_idx, content_idx, %{type: :code, lang: lang, content: content}) do
    ~s(<div class="code">
      <pre phx-click="edit" phx-value-slide_idx="#{slide_idx}" phx-value-content_idx="#{
      content_idx
    }">
        <code class="#{lang}">#{content}</code>
      </pre>
      <button phx-click="run" phx-value-slide_idx="#{slide_idx}" phx-value-content_idx="#{
      content_idx
    }">Run</button>
    </div>)
  end

  def parse_slide(_lide_idx, _content_idx, %{type: :error, content: content}) do
    ~s(<div class="error">#{content}</div>)
  end

  def parse_slide(_, _, %{type: :html, content: content}) do
    content
  end

  def parse_slide(_slide_idx, _content_idx, _) do
    ""
  end

  def get_background(slide) do
    Enum.find(slide, %{content: ""}, fn x -> Map.get(x, :type) == :background end).content
  end
end
