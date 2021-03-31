defmodule PersonalBoardV2Web.PageController do
  use PersonalBoardV2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
