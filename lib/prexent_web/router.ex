defmodule PrexentWeb.Router do
  use PrexentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Phoenix.LiveView.Flash
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PrexentWeb do
    pipe_through :browser

    live "/", SlidesLive
    live "/:slide", SlidesLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", PrexentWeb do
  #   pipe_through :api
  # end
end
