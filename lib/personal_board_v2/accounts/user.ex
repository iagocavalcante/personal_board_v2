defmodule PersonalBoardV2.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :avatar, :string
    field :email, :string
    field :name, :string
    field :uid, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :uid, :name, :avatar])
    |> validate_required([:email, :uid, :name, :avatar])
  end
end
