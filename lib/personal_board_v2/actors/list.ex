defmodule PersonalBoardV2.Actors.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :position, :integer
    field :title, :string

    has_many :cards, PersonalBoardV2.Actors.Card
    belongs_to :board, PersonalBoardV2.Actors.Board

    timestamps()
  end

  @doc false
  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :position, :board_id])
    |> validate_required([:title])
  end
end
