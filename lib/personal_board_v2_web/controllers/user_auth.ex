defmodule PersonalBoardV2Web.UserAuth do
  @moduledoc """
  Functions related to authentication.
  """
  import Plug.Conn
  import Phoenix.Controller

  import PersonalBoardV2Web.Gettext

  alias PersonalBoardV2Web.Router.Helpers, as: Routes

  def log_in_user(conn, user) do
    conn
    |> put_flash(:info, "Successfully authenticated.")
    |> put_session(:current_user, user)
    |> configure_session(renew: true)
    |> redirect(to: "/boards")
  end

  @doc """
  Used for routes that require the user to not be authenticated.
  """
  def redirect_if_user_is_authenticated(conn, _opts) do
    if conn.private.plug_session["current_user"] do
      conn
      |> redirect(to: signed_in_path(conn))
      |> halt()
    else
      conn
    end
  end

  @doc """
  Used for routes that require the user to be authenticated.

  If you want to enforce the user email is confirmed before
  they use the application at all, here would be a good place.
  """
  def require_authenticated_user(conn, _opts) do
    if conn.private.plug_session["current_user"] do
      conn
    else
      conn
      |> put_flash(:error, gettext("Você deve estar logado para acessar esta página."))
      |> maybe_store_return_to()
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  defp maybe_store_return_to(%{method: "GET"} = conn) do
    %{request_path: request_path, query_string: query_string} = conn
    return_to = if query_string == "", do: request_path, else: request_path <> "?" <> query_string
    put_session(conn, :user_return_to, return_to)
  end

  defp maybe_store_return_to(conn), do: conn

  defp signed_in_path(_conn), do: "/boards"

  def format_error(:unauthorized) do
    gettext("Você não possui permissão para realizar esta ação.")
  end
end
