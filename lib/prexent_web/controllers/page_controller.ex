defmodule PrexentWeb.PageController do
  use PrexentWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
