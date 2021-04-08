defmodule PersonalBoardV2Web.PageController do
  use PersonalBoardV2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html", current_user: get_session(conn, :current_user))
  end

  def policy(conn, _params) do
    render(conn, "policy.html", current_user: get_session(conn, :current_user))
  end

  def terms(conn, _params) do
    render(conn, "terms.html", current_user: get_session(conn, :current_user))
  end
end
