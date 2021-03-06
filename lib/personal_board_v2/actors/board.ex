defmodule PersonalBoardV2.Actors.Board do
  use Ecto.Schema
  import Ecto.Changeset

  schema "boards" do
    field :img_url, :string
    field :title, :string
    has_many :lists, PersonalBoardV2.Actors.List
    belongs_to :user, PersonalBoardV2.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:title, :img_url, :user_id])
    |> validate_required([:title])
  end
end
