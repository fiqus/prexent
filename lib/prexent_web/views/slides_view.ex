defmodule PrexentWeb.SlidesView do
  use PrexentWeb, :view

  def parse_slide(slide_idx, content_idx, %{type: :code, lang: lang, content: content}) do
    phx_values_idx = ~s(phx-value-slide_idx="#{slide_idx}" phx-value-content_idx="#{content_idx}")
    ~s(<div class="code">
      <pre><code class="#{lang}">#{content}</code></pre>
      <div class="buttons">
        <button phx-click="edit" #{phx_values_idx}>Edit</button>
        <button phx-click="run" #{phx_values_idx}>Run</button>
      </div>
    </div>)
  end

  def parse_slide(slide_idx, content_idx, %{type: :edit, content: content}) do
    phx_values_idx = ~s(phx-value-slide_idx="#{slide_idx}" phx-value-content_idx="#{content_idx}")
    onclick = "onCodeApply(this)"

    ~s(<div class="code">
      <pre><code class="nohighlight" contenteditable="true" #{phx_values_idx} onchange="onCodeChange">#{
      content
    }</code></pre>
      <div class="buttons">
        <button phx-click="cancel" #{phx_values_idx}>Cancel</button>
        <button onclick="#{onclick}">Apply</button>
      </div>
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

  def get_global_background(slide) do
    Enum.find(slide, %{content: ""}, fn x -> Map.get(x, :type) == :global_background end).content
  end

  def get_slide_background(slide) do
    Enum.find(slide, %{content: ""}, fn x -> Map.get(x, :type) == :slide_background end).content
  end

  def get_header(slide) do
    Enum.find(slide, %{content: ""}, fn x -> Map.get(x, :type) == :header end).content
  end

  def get_footer(slide) do
    Enum.find(slide, %{content: ""}, fn x -> Map.get(x, :type) == :footer end).content
  end

  def get_custom_css(slide) do
    slide
    |> Enum.filter(&(Map.get(&1, :type) == :custom_css))
    |> Enum.map(& &1.content)
  end

  def get_slide_classes(slide) do
    Enum.find(slide, %{content: []}, fn x -> Map.get(x, :type) == :slide_classes end).content
  end
end
