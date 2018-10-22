defmodule BookBuddyWeb.Router do
  use BookBuddyWeb, :router

  # alias BookBuddyWeb.{BookController, UserController}

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", BookBuddyWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/", PageController, :index)

    resources("/books", BookController)
    resources("/users", UserController)
  end

  # Other scopes may use custom stacks.
  # scope "/api", BookBuddyWeb do
  #   pipe_through :api
  # end
end
