defmodule PrexentWeb.SlidesLive do
  @moduledoc false

  use PrexentWeb, :live_view

  def render(assigns) do
    PrexentWeb.SlidesView.render("slides.html", assigns)
  end

  def mount(_, socket) do
    slides = Prexent.Parser.to_parsed_list("demo_files/demo1.md")
    {:ok, assign(socket, slides: slides, slide: 0)}
  end

  def handle_event("keyup", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, assign(socket, :slide, max(socket.assigns.slide - 1, 0))}
  end

  def handle_event("keyup", %{"key" => key}, socket) when key in ["ArrowRight", " "] do
    {:noreply,
     assign(socket, :slide, min(socket.assigns.slide + 1, length(socket.assigns.slides) - 1))}
  end

  def handle_event("keyup", k, socket) do
    IO.inspect(k)
    {:noreply, socket}
  end
end
