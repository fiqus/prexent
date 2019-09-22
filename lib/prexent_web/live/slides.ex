defmodule PrexentWeb.SlidesLive do
  @moduledoc false
  use PrexentWeb, :live_view

  def render(assigns) do
    PrexentWeb.SlidesView.render("slides.html", assigns)
  end

  def mount(_, socket) do
    source_md = Application.get_env(:prexent, :source_md) || "demo_files/demo1.md"
    slides = Prexent.Parser.to_parsed_list(source_md)
    {:ok, assign(socket, slides: slides, slide: 0, code_runners: %{}, pid_slides: %{})}
  end

  def handle_params(%{"slide" => slide}, _uri, socket) do
    num = parse_slide_num(socket, slide)
    {:noreply, assign(socket, slide: num)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  def handle_event("forward_backward", %{"clicked" => clicked}, socket) do
    forward_backward = String.to_integer(clicked) - socket.assigns.slide
    handle_slide_change(socket, socket.assigns.slide + forward_backward)
  end

  def handle_event("keyup", %{"key" => "ArrowLeft"}, socket) do
    handle_slide_change(socket, max(socket.assigns.slide - 1, 0))
  end

  def handle_event("keyup", %{"key" => "ArrowDown"}, socket) do
    handle_slide_change(socket, max(socket.assigns.slide - 2, 0))
  end

  def handle_event("keyup", %{"key" => "ArrowRight"}, socket) do
    handle_slide_change(socket, min(socket.assigns.slide + 1, length(socket.assigns.slides) - 1))
  end

  def handle_event("keyup", %{"key" => "ArrowUp"}, socket) do
    handle_slide_change(socket, max(socket.assigns.slide + 2, 0))
  end

  def handle_event("run", %{"slide_idx" => slide_idx, "content_idx" => content_idx}, socket) do
    block = get_slide_block(socket, slide_idx, content_idx)

    {:ok, _, id} =
      Exexec.run(block.runner <> " " <> block.filename,
        stdout: self(),
        stderr: self(),
        monitor: true
      )

    {
      :noreply,
      assign(
        socket,
        code_runners: Map.put(socket.assigns.code_runners, parse_slide_num(slide_idx), ""),
        pid_slides: Map.put(socket.assigns.pid_slides, id, parse_slide_num(slide_idx))
      )
    }
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

  def handle_event("edit", %{"slide_idx" => slide_idx, "content_idx" => content_idx}, socket) do
    block =
      get_slide_block(socket, slide_idx, content_idx)
      |> Map.put(:type, :edit)

    {:noreply, socket |> put_slide_block(slide_idx, content_idx, block)}
  end

  def handle_event("cancel", %{"slide_idx" => slide_idx, "content_idx" => content_idx}, socket) do
    block =
      get_slide_block(socket, slide_idx, content_idx)
      |> Map.put(:type, :code)

    {:noreply, socket |> put_slide_block(slide_idx, content_idx, block)}
  end

  def handle_event(event, data, socket) do
    Logger.warn("Unhandled event #{inspect(event)} with data: #{inspect(data)}")
    {:noreply, socket}
  end

  defp do_output(class, id, data, socket) do
    str = "<span class='#{class}'>#{data}</span>"

    slide_idx = Map.get(socket.assigns.pid_slides, id)

    {
      :noreply,
      assign(
        socket,
        :code_runners,
        Map.put(
          socket.assigns.code_runners,
          slide_idx,
          Map.get(socket.assigns.code_runners, slide_idx) <> str
        )
      )
    }
  end

  def handle_info({:stdout, id, data}, socket), do: do_output("", id, data, socket)
  def handle_info({:stderr, id, data}, socket), do: do_output("error", id, data, socket)

  def handle_info({:DOWN, id, _, _, :normal}, socket),
    do: do_output("ok", id, "Program exited normally", socket)

  def handle_info({:DOWN, id, _, _, {:exit_status, n}}, socket),
    do: do_output("error", id, "Program exited with status #{n}", socket)

  def handle_info(data, socket) do
    Logger.warn("Unhandled info with data: #{inspect(data)}")
    {:noreply, socket}
  end

  defp get_slide_block(socket, slide_idx, content_idx) do
    socket.assigns.slides
    |> Enum.at(parse_slide_num(slide_idx), [])
    |> Enum.at(parse_slide_num(content_idx))
  end

  defp put_slide_block(socket, slide_idx, content_idx, block) do
    slide_idx = parse_slide_num(slide_idx)
    content_idx = parse_slide_num(content_idx)

    slides =
      Enum.with_index(socket.assigns.slides)
      |> Enum.map(fn {slide, sidx} ->
        Enum.with_index(slide)
        |> Enum.map(fn {cblock, cidx} ->
          if sidx == slide_idx and cidx == content_idx do
            block
          else
            cblock
          end
        end)
      end)

    assign(socket, :slides, slides)
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

    if valid_slide?(socket, num), do: num, else: 0
  end

  defp parse_slide_num(slide) when is_integer(slide), do: slide

  defp parse_slide_num(slide) do
    case(Integer.parse(slide)) do
      {int, _} -> int
      _ -> 0
    end
  end
end
