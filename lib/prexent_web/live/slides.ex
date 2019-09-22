defmodule PrexentWeb.SlidesLive do
  @moduledoc false
  use PrexentWeb, :live_view

  alias Porcelain.Process, as: Proc

  def render(assigns) do
    PrexentWeb.SlidesView.render("slides.html", assigns)
  end

  def mount(_, socket) do
    slides = Prexent.Parser.to_parsed_list("demo_files/demo1.md")
    {:ok, assign(socket, slides: slides, slide: 0, code_runners: %{}, pid_slides: %{})}
  end

  def handle_params(%{"slide" => slide}, _uri, socket) do
    num = parse_slide_num(socket, slide)
    {:noreply, assign(socket, slide: num)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("keyup", %{"key" => "ArrowLeft"}, socket) do
    handle_slide_change(socket, max(socket.assigns.slide - 1, 0))
  end

  def handle_event("keyup", %{"key" => "ArrowRight"}, socket) do
    handle_slide_change(socket, min(socket.assigns.slide + 1, length(socket.assigns.slides) - 1))
  end

  def handle_event("run", %{"slide_idx" => slide_idx, "content_idx" => content_idx}, socket) do
    code = socket.assigns.slides
           |> Enum.at(parse_slide_num(slide_idx))
           |> Enum.at(parse_slide_num(content_idx))

    IO.inspect(code.filename)
    proc = %Proc{pid: pid} = Porcelain.spawn_shell(
      "elixir " <> code.filename,
      in: :receive,
      err: {:send, self()},
      out: {:send, self()},
      result: :keep
    )

    {
      :noreply,
      assign(
        socket,
        [
          code_runners: Map.put(socket.assigns.code_runners, parse_slide_num(slide_idx), ""),
          pid_slides: Map.put(socket.assigns.pid_slides, pid, parse_slide_num(slide_idx))
        ]
      )
    }
  end

  def handle_info({pid, :data, :out, data}, socket) do
    slide_idx = Map.get(socket.assigns.pid_slides, pid)
    {
      :noreply,
      assign(
        socket,
        :code_runners,
        Map.put(socket.assigns.code_runners, slide_idx, Map.get(socket.assigns.code_runners, slide_idx) <> data)
      )
    }
  end
  def handle_info(data, socket) do
    IO.inspect(data )
    {:noreply, socket}
    # slide_idx = Map.get(socket.assigns.pid_slides, pid)
    # {:noreply, assign(socket, :code_runners, Map.put(socket.assigns.code_runners, slide_idx, Map.get(socket.assigns.code_runners, slide_idx) <> "PROCESS FINISHED"))}
  end

  def handle_event("close", %{"slide_idx" => slide_idx}, socket) do
    {
      :noreply,
      assign(
        socket,
        :code_runners,
        Map.delete(socket.assigns.code_runners, parse_slide_num(slide_idx))
      )
    }
  end

  def handle_event(_ev, _data, socket) do
    {:noreply, socket}
  end

  defp handle_slide_change(socket, slide) do
    num = parse_slide_num(socket, slide)

    if socket.assigns.slide != num do
      {
        :noreply,
        live_redirect(
          socket,
          to: Routes.live_path(socket, __MODULE__, num)
        )
      }
    else
      {:noreply, socket}
    end
  end

  defp valid_slide?(
         %{
           assigns: %{
             slides: slides
           }
         },
         num
       ) do
    num >= 0 and num <= length(slides) - 1
  end

  defp parse_slide_num(socket, slide) do
    num = parse_slide_num(slide)

    if valid_slide?(socket, num),
       do: num,
       else: 0
  end

  defp parse_slide_num(slide) when is_integer(slide), do: slide

  defp parse_slide_num(slide) do
    case(Integer.parse(slide)) do
      {int, _} -> int
      _ -> 0
    end
  end
end
