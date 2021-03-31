defmodule PersonalBoardV2.Card do
  import Ecto.Query, warn: false
  alias PersonalBoardV2.Repo

  alias PersonalBoardV2.Actors.Card

  def cards_for_list(id) do
    q =
      from Card,
        where: [list_id: ^id],
        order_by: [asc: :position],
        select: [:id, :title, :description]

    Repo.all(q)
  end

  def move_card_to_list(card_id, to_list, to_position) do
    card = get_card!(card_id)
    placeholder = %Card{card | position: to_position}

    PersonalBoardV2.Repo.transaction(fn ->
      reorder_list_after_removing_card(card)
      reorder_list_after_adding_card(placeholder)
      update_card(card, %{position: to_position, list_id: to_list})
    end)
  end

  def reorder_list_after_adding_card(%Card{list_id: list_id, position: position}) do
    from(c in Card,
      where: ^position < c.position and c.list_id == ^list_id,
      update: [inc: [position: 1]]
    )
    |> Repo.update_all([])
  end

  def reorder_list_after_removing_card(%Card{list_id: list_id, position: position}) do
    from(c in Card,
      where: ^position < c.position and c.list_id == ^list_id,
      update: [inc: [position: -1]]
    )
    |> Repo.update_all([])
  end

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  def change_card(%Card{} = card) do
    Card.changeset(card, %{})
  end
end
