defmodule HakatonBackendWeb.Router do
  use HakatonBackendWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug HakatonBackendWeb.Plug.EnsureAuthenticated
  end

  scope "/api", HakatonBackendWeb do
    pipe_through :api

    post("/login", SessionController, :login)
    post("/register", SessionController, :register)

    scope "/" do
      pipe_through :authenticated
      post("/refresh", SessionController, :refresh_token)
    end
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:hakaton_backend, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: HakatonBackendWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
