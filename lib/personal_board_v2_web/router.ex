defmodule PersonalBoardV2Web.Router do
  alias PersonalBoardV2Web.BoardController
  alias PersonalBoardV2Web.ListController
  use PersonalBoardV2Web, :router
  import PersonalBoardV2Web.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PersonalBoardV2Web.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PersonalBoardV2Web do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :index
  end

  scope "/", PersonalBoardV2Web do
    pipe_through :browser
    get "/politicas-privacidade", PageController, :policy
    get "/termos-uso", PageController, :terms

  end

  scope "/", PersonalBoardV2Web do
    pipe_through [:browser, :require_authenticated_user]

    live "/boards", BoardsLive, :index
    live "/boards/new", BoardsLive, :new
    live "/boards/:id/edit", BoardsLive, :edit
    live "/cards/new", BoardsLive, :new_card
    live "/cards/:id/edit", BoardsLive, :edit_card
    live "/lists/new", BoardsLive, :new_list
    live "/lists/:id/edit", BoardsLive, :edit_list
  end

  scope "/auth", PersonalBoardV2Web do
    pipe_through [:browser]

    get("/:provider", AuthController, :request)
    get("/:provider/callback", AuthController, :callback)
    post("/:provider/callback", AuthController, :callback)
    post("/logout", AuthController, :delete)
  end

  scope "/admin" do
    pipe_through [:browser, :require_authenticated_user]

    resources "/boards", BoardController
    resources "/lists", ListController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PersonalBoardV2Web do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PersonalBoardV2Web.Telemetry
    end
  end
end
