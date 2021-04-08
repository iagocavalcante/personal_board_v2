defmodule PersonalBoardV2Web.AuthController do
  use PersonalBoardV2Web, :controller
  plug Ueberauth

  alias PersonalBoardV2Web.UserAuth

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case PersonalBoardV2.Accounts.find_or_create(auth) do
      {:ok, user} ->
        UserAuth.log_in_user(conn, user)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason.errors)
        |> redirect(to: "/")
    end
  end
end
