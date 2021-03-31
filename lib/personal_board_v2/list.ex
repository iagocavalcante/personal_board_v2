defmodule PersonalBoardV2.List do
  import Ecto.Query, warn: false
  alias PersonalBoardV2.Repo

  def reorder_lists(start, the_end) when is_binary(start) or is_binary(the_end) do
    raise "reorder_lists takes integers"
  end

  def reorder_lists(start, the_end) when start < the_end do
    from(l in PersonalBoardV2.Actors.List,
      where: ^start < l.position and l.position <= ^the_end,
      update: [inc: [position: -1]]
    )
    |> Repo.update_all([])
  end

  def reorder_lists(start, the_end) do
    from(l in PersonalBoardV2.Actors.List,
      where: ^the_end <= l.position and l.position < ^start,
      update: [inc: [position: 1]]
    )
    |> Repo.update_all([])
  end

  def list_lists do
    Repo.all(PersonalBoardV2.Actors.List)
  end

  def lists_for_board(id) do
    query =
      from PersonalBoardV2.Actors.List,
        where: [board_id: ^id],
        order_by: [asc: :position],
        preload: [:cards],
        select: [:id, :title, :board_id, :position]

    Repo.all(query)
  end

  def get_list!(id), do: Repo.get!(PersonalBoardV2.Actors.List, id)

  def create_list(attrs \\ %{}) do
    with_position =
      case attrs do
        %{position: _} ->
          attrs

        _ ->
          Map.put(attrs, "position", next_list_position())
      end

    %PersonalBoardV2.Actors.List{}
    |> PersonalBoardV2.Actors.List.changeset(with_position)
    |> Repo.insert()
  end

  def update_list(%PersonalBoardV2.Actors.List{} = list, attrs) do
    list
    |> PersonalBoardV2.Actors.List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%PersonalBoardV2.Actors.List{} = list) do
    Repo.delete(list)
  end

  def next_list_position do
    result =
      from(list in PersonalBoardV2.Actors.List, select: max(list.position))
      |> Repo.one()

    case result do
      nil -> 0
      int -> int + 1
    end
  end

  def change_list(%PersonalBoardV2.Actors.List{} = list) do
    PersonalBoardV2.Actors.List.changeset(list, %{})
  end
end
