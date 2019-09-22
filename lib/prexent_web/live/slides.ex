defmodule PrexentWeb.SlidesLive do
  @moduledoc false
  use PrexentWeb, :live_view

  def render(assigns) do
    PrexentWeb.SlidesView.render("slides.html", assigns)
  end

  def mount(_params, socket) do
    Phoenix.PubSub.subscribe(Prexent.PubSub, "slide")
    source_md = Application.get_env(:prexent, :source_md) || "demo_files/demo1.md"
    slides = Prexent.Parser.to_parsed_list(source_md)

    {:ok, assign(socket, slides: slides, slide: 0, code_runners: %{}, pid_slides: %{})}
  end

  def handle_params(%{"slide" => slide}, _uri, socket) do
    num = parse_slide_num(socket, slide)
    {:noreply, assign(socket, slide: num)}
  end

  def handle_params(%{"pslide" => slide}, uri, socket) do
    handle_params(%{"slide" => slide}, uri, socket |> assign(:presenter, true))
  end

  def handle_params(params, uri, socket) do
    if Regex.match?(~r/\/presenter/, uri) do
      handle_params(%{"pslide" => 0}, uri, socket)
    else
      Logger.warn("Unhandled params at #{inspect(uri)} with: #{inspect(params)}")
      {:noreply, socket}
    end
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

  def handle_event("keyup", _data, socket) do
    {:noreply, socket}
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
    slide_num = parse_slide_num(slide_idx)

    slide_pid =
      socket.assigns.pid_slides
      |> Enum.find(fn {_, val} -> val == slide_num end)

    if slide_pid != nil, do: Exexec.stop(elem(slide_pid, 0))

    {
      :noreply,
      assign(
        socket,
        code_runners: Map.delete(socket.assigns.code_runners, slide_num),
        pid_slides: Map.delete(socket.assigns.pid_slides, slide_pid)
      )
    }
  end

  def handle_event("stop", %{"slide_idx" => slide_idx}, socket) do
    slide_num = parse_slide_num(slide_idx)

    slide_pid =
      socket.assigns.pid_slides
      |> Enum.find(fn {_, val} -> val == slide_num end)

    if slide_pid != nil, do: Exexec.stop(elem(slide_pid, 0))
    {:noreply, socket}
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

  def handle_event(
        "apply",
        %{"slide_idx" => slide_idx, "content_idx" => content_idx, "code" => code},
        socket
      ) do
    filename = System.tmp_dir!() <> "/prexent_slide_#{slide_idx}_#{content_idx}"
    File.write!(filename, code)

    block =
      get_slide_block(socket, slide_idx, content_idx)
      |> Map.put(:type, :code)
      |> Map.put(:content, code)
      |> Map.put(:filename, filename)

    {:noreply, socket |> put_slide_block(slide_idx, content_idx, block)}
  end

  def handle_event(event, data, socket) do
    Logger.warn("Unhandled event #{inspect(event)} with data: #{inspect(data)}")
    {:noreply, socket}
  end

  defp do_output(class, id, data, socket) do
    str = "<span class='#{class}'>#{data}</span>"

    slide_idx = Map.get(socket.assigns.pid_slides, id)

    if slide_idx != nil && Map.get(socket.assigns.code_runners, slide_idx) != nil do
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
    else
      {:noreply, socket}
    end
  end

  def handle_info({:stdout, id, data}, socket), do: do_output("", id, data, socket)
  def handle_info({:stderr, id, data}, socket), do: do_output("error", id, data, socket)

  def handle_info({:DOWN, id, _, _, :normal}, socket) do
    {_, socket} = do_output("ok", id, "Program exited normally", socket)
    socket = assign(socket, :pid_slides, Map.delete(socket.assigns.pid_slides, id))
    {:noreply, socket}
  end

  def handle_info({:DOWN, id, _, _, {:exit_status, n}}, socket) do
    {_, socket} = do_output("error", id, "Program exited with status #{n}", socket)
    socket = assign(socket, :pid_slides, Map.delete(socket.assigns.pid_slides, id))
    {:noreply, socket}
  end

  def handle_info({:slide_change, num}, socket) do
    baseurl =
      if Map.get(socket.assigns, :presenter, false),
        do: "/presenter",
        else: ""

    {:noreply, live_redirect(socket, to: "#{baseurl}/#{num}")}
  end

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

  defp handle_slide_change(%{assigns: assigns} = socket, slide) do
    num = parse_slide_num(socket, slide)

    is_editing? =
      Enum.at(assigns.slides, assigns.slide)
      |> Enum.find(&(&1.type == :edit)) != nil

    if !is_editing? and socket.assigns.slide != num do
      Phoenix.PubSub.broadcast(Prexent.PubSub, "slide", {:slide_change, num})
    end

    {:noreply, socket}
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
