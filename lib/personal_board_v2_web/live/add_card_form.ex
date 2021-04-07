defmodule PersonalBoardV2Web.AddCardForm do
  @moduledoc """
  LiveView Component to display a form for create board.
  """
  use PersonalBoardV2Web, :live_component
  alias PersonalBoardV2.Actors.Card

  def mount(_session, socket) do
    {:ok, assign(socket, :card)}
  end

  def handle_event("add_card", %{"card" => %{"title" => title, "list_id" => list_id}}, socket) do
    ## Make room at beginning of list, kind of a hack
    PersonalBoardV2.Card.reorder_list_after_adding_card(%Card{list_id: list_id, position: -1})
    case PersonalBoardV2.Card.create_card(%{"title" => title, "list_id" => list_id, "position" => 0}) do
      {:ok, board} ->
        {:noreply,
          socket
           |> put_flash(:info, gettext("Cartão salvo com sucesso."))
           |> push_redirect(to: socket.assigns.return_to)}

      {:error, error} ->
        IO.inspect(error.errors)
    end
  end
end
