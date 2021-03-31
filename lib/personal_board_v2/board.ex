defmodule PersonalBoardV2.Board do
  import Ecto.Query, warn: false
  alias PersonalBoardV2.Repo

  alias PersonalBoardV2.Actors.Board

  def list_boards do
    Repo.all(Board)
  end

  def get_board!(id), do: Repo.get!(Board, id)

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
