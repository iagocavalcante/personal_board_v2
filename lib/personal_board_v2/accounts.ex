defmodule PersonalBoardV2.Accounts do
  require Logger
  alias Ueberauth.Auth
  alias PersonalBoardV2.Repo

  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias PersonalBoardV2.Accounts.User

  def get_by(attr \\ %{}), do: Repo.get_by(attr)

  def find_or_create(%Auth{} = auth) do
    user =
      email_from_auth(auth)
      |> get_user_for_email()

    if user do
      {:ok, user}
    else
      create_user(basic_info(auth))
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  defp get_user_for_email(email) do
    IO.inspect(Repo.get_by(User, email: email))
  end

  # github does it this way
  defp avatar_from_auth(%{info: %{urls: %{avatar_url: image}}}), do: image

  # facebook does it this way
  defp avatar_from_auth(%{info: %{image: image}}), do: image

  defp email_from_auth(%{info: %{email: email}}), do: email

  # default case if nothing matches
  defp avatar_from_auth(auth) do
    Logger.warn("#{auth.provider} needs to find an avatar URL!")
    Logger.debug(Jason.encode!(auth))
    nil
  end

  defp basic_info(auth) do
    email = email_from_auth(auth)
    IO.inspect(auth.uid)

    case auth.strategy do
      Ueberauth.Strategy.Facebook ->
        %{
          uid: auth.uid,
          name: name_from_auth(auth),
          email: email,
          avatar: avatar_from_auth(auth),
          provider: "facebook"
        }

      Ueberauth.Strategy.Google ->
        %{
          uid: Kernel.inspect(auth.uid),
          name: name_from_auth(auth),
          email: email,
          avatar: avatar_from_auth(auth),
          provider: "google"
        }

      Ueberauth.Strategy.Github ->
        %{
          uid: Kernel.inspect(auth.uid),
          name: name_from_auth(auth),
          email: email,
          avatar: avatar_from_auth(auth),
          provider: "github"
        }
    end
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      if Enum.empty?(name) do
        auth.info.nickname
      else
        Enum.join(name, " ")
      end
    end
  end
end
