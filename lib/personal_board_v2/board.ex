defmodule PersonalBoardV2.Board do
  import Ecto.Query, warn: false
  alias PersonalBoardV2.Repo

  alias PersonalBoardV2.Actors.Board

  def list_boards(user_id) do
    query =
      from PersonalBoardV2.Actors.Board,
        where: [user_id: ^user_id]

    query
    |> Repo.all()
  end

  def get_board_by_id!(id, user_id) do
    query =
      from PersonalBoardV2.Actors.Board,
        where: [user_id: ^user_id],
        where: [id: ^id]

    query
    |> Repo.one()
  end

  def get_board!(user_id) do
    query =
      from PersonalBoardV2.Actors.Board,
        where: [user_id: ^user_id],
        limit: 1

    query
    |> Repo.one()
  end

  def create_board(attrs \\ %{}) do
    %Board{}
    |> Board.changeset(attrs)
    |> Repo.insert()
  end

  def update_board(%Board{} = board, attrs) do
    board
    |> Board.changeset(attrs)
    |> Repo.update()
  end

  def delete_board(%Board{} = board) do
    Repo.delete(board)
  end

  def change_board(%Board{} = board) do
    Board.changeset(board, %{})
  end
end
