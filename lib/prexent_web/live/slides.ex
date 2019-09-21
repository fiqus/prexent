defmodule PrexentWeb.SlidesLive do
  @moduledoc false

  use Phoenix.LiveView
  use Phoenix.HTML

  def render(assigns) do
    Phoenix.View.render(PrexentWeb.PageView, "slides.html", assigns)
  end

  def mount(_ , socket) do
    {:ok, assign(socket, slides: ["test slide 1", "test slide 2", "test slide 3"], slide: 0)}
  end

  def handle_event("keyup", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, assign(socket, :slide, max(socket.assigns.slide - 1, 0))}
  end

  def handle_event("keyup", %{"key" => "ArrowRight"}, socket) do
    {:noreply, assign(socket, :slide, min(socket.assigns.slide + 1, length(socket.assigns.slides) - 1))}
  end

  def handle_event("keyup", _, socket) do
    {:noreply, socket}
  end
end
