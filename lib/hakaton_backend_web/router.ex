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

    get("/user/:user_id", UserController, :show)

    scope "/events" do
      get("/", EventController, :index)
      get("/:event_id", EventController, :show)
      get("/:event_id/attendees", EventController, :event_attendees)
    end
  end

  scope "/api", HakatonBackendWeb do
    pipe_through [:api, :authenticated]

    put("/send-friend-request/:recipient_id", UserController, :send_friend_request)
    put("/accept-friend-request/:sender_id", UserController, :accept_friend_request)
    put("/refuse-friend-request/:sender_id", UserController, :refuse_friend_request)
    post("/refresh", SessionController, :refresh_token)

    scope "/user" do
      get("/suggested-friends", UserController, :get_suggested_friends)
      get("/friends", UserController, :get_friends)
      get("/friend-requests", UserController, :get_friend_requests)
      get("/own-events", UserController, :get_own_events)
    end

    scope "/conversation" do
      get("/", ChatController, :index)
      get("/:conversation_id", ChatController, :show)

      post("/:conversation_id/:friend_id", ChatController, :send_message)
    end

    scope "/events" do
      post("/create", EventController, :create)
      put("/:event_id/attend", EventController, :attend)
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
