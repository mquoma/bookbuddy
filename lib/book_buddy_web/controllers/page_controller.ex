defmodule BookBuddyWeb.PageController do
  use BookBuddyWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
