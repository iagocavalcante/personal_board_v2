defmodule PersonalBoardV2Web.BoardsLive do
  use PersonalBoardV2Web, :live_view

  alias PersonalBoardV2.Actors.Card

  @topic "board_updates"

  def render(assigns) do
    PersonalBoardV2Web.BoardView.render("board.html", assigns)
  end

  def mount(_params, _session, socket) do
    Phoenix.PubSub.subscribe(PersonalBoardV2.PubSub, @topic)

    current_board = PersonalBoardV2.Board.get_board!(1)

    {:ok,
     assign(socket,
       lists: PersonalBoardV2.List.lists_for_board(1),
       current_board: current_board,
       boards: boards_to_select(current_board),
       show_boards: false,
       show_board_composer: false,
       show_card_composer: 0,
       show_list_actions: false,
       show_list_composer: false,
       edit_list_title: 0,
       edit_card_title: 0
     )}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, gettext("Novo Quadro"))
    |> assign(:board, %PersonalBoardV2.Actors.Board{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, gettext("Quadros"))
    |> assign(:board, nil)
  end

  defp apply_action(socket, nil, _params) do
    socket
    |> assign(:page_title, gettext("Quadros"))
    |> assign(:board, nil)
  end

  def update_board_for_subscribers(board_id) do
    Phoenix.PubSub.broadcast_from!(
      PersonalBoardV2.PubSub,
      self(),
      @topic,
      {__MODULE__, {:update_board, board_id}}
    )
  end

  def handle_event("show_boards", %{"should_show" => value}, socket) do
    case value do
      "true" -> {:noreply, assign(socket, show_boards: true)}
      "false" -> {:noreply, assign(socket, show_boards: false)}
    end
  end

  def handle_event("set_current_board", %{"board_id" => id}, socket) do
    board = PersonalBoardV2.Board.get_board!(id)

    {:noreply,
     assign(socket,
       current_board: board,
       boards: boards_to_select(board),
       show_boards: false,
       lists: PersonalBoardV2.List.lists_for_board(board.id)
     )}
  end

  def handle_event(
        "show_list_actions",
        %{"should_show" => "true", "left" => x, "top" => y, "list_id" => list_id},
        socket
      ) do
    {:noreply,
     assign(socket,
       show_list_actions: true,
       list_actions_x: x,
       list_actions_y: y,
       list_actions_list_id: list_id
     )}
  end

  def handle_event("show_board_composer", %{"should_show" => value}, socket) do
    case value do
      "true" -> {:noreply, assign(socket, show_board_composer: true)}
      "false" -> {:noreply, assign(socket, show_board_composer: false)}
    end
  end

  def handle_event("add_board", %{"board" => %{"title" => title}}, socket) do
    case PersonalBoardV2.Board.create_board(%{"title" => title}) do
      {:ok, board} ->
        {:noreply,
         assign(socket,
           lists: PersonalBoardV2.List.lists_for_board(board.id),
           current_board: board,
           boards: boards_to_select(board),
           show_board_composer: 0
         )}

      {:error, error} ->
        IO.inspect(error.errors)
    end
  end

  def handle_event("show_list_actions", %{"should_show" => "false"}, socket) do
    {:noreply, assign(socket, show_list_actions: false)}
  end

  def handle_event("show_list_composer", %{"should_show" => value}, socket) do
    case value do
      "true" -> {:noreply, assign(socket, show_list_composer: true)}
      "false" -> {:noreply, assign(socket, show_list_composer: false)}
    end
  end

  def handle_event("add_list", %{"list" => %{"title" => title, "board_id" => id}}, socket) do
    PersonalBoardV2.List.create_list(%{"title" => title, "board_id" => id})

    update_board_for_subscribers(socket.assigns.current_board.id)
    {:noreply, assign(socket, lists: PersonalBoardV2.List.lists_for_board(id))}
  end

  def handle_event("reorder_list", %{"list_id" => list_id, "to_position" => to_position}, socket) do
    list = PersonalBoardV2.List.get_list!(list_id)

    PersonalBoardV2.Repo.transaction(fn ->
      PersonalBoardV2.List.reorder_lists(list.position, to_position)
      PersonalBoardV2.List.update_list(list, %{position: to_position})
    end)

    update_board_for_subscribers(socket.assigns.current_board.id)
    {:noreply, assign(socket, lists: current_lists(socket))}
  end

  def handle_event("archive_list", %{"list_id" => list_id}, socket) do
    list = PersonalBoardV2.List.get_list!(list_id)
    PersonalBoardV2.List.delete_list(list)

    update_board_for_subscribers(socket.assigns.current_board.id)
    {:noreply, assign(socket, lists: current_lists(socket), show_list_actions: false)}
  end

  def handle_event("move_card", params, socket) do
    %{
      "to_list" => to_list,
      "to_position" => to_position,
      "card_id" => card_id
    } = params

    PersonalBoardV2.Card.move_card_to_list(card_id, to_list, to_position)

    update_board_for_subscribers(socket.assigns.current_board.id)
    {:noreply, assign(socket, lists: current_lists(socket))}
  end

  def handle_event("add_card", %{"card" => %{"title" => title, "list_id" => list_id}}, socket) do
    ## Make room at beginning of list, kind of a hack
    PersonalBoardV2.Card.reorder_list_after_adding_card(%Card{list_id: list_id, position: -1})

    PersonalBoardV2.Card.create_card(%{"title" => title, "list_id" => list_id, "position" => 0})
    update_board_for_subscribers(socket.assigns.current_board.id)
    {:noreply, assign(socket, lists: current_lists(socket), show_card_composer: 0)}
  end

  def handle_event("show_card_composer", %{"list_id" => list_id}, socket) do
    {:noreply,
     assign(socket, show_list_actions: false, show_card_composer: String.to_integer(list_id))}
  end

  def handle_event("edit_list_title", %{"list_id" => list_id}, socket) do
    {:noreply, assign(socket, edit_list_title: String.to_integer(list_id))}
  end

  def handle_event("update_list_title", %{"list_id" => list_id, "title" => title}, socket) do
    list = PersonalBoardV2.List.get_list!(list_id)

    if list.title != title do
      PersonalBoardV2.List.update_list(list, %{title: title})
      update_board_for_subscribers(socket.assigns.current_board.id)
      {:noreply, assign(socket, edit_list_title: 0, lists: current_lists(socket))}
    else
      {:noreply, assign(socket, edit_list_title: 0)}
    end
  end

  def handle_event("edit_card_title", %{"card_id" => card_id}, socket) do
    {:noreply, assign(socket, edit_card_title: String.to_integer(card_id))}
  end

  def handle_event("update_card_title", %{"card_id" => card_id, "title" => title}, socket) do
    card = PersonalBoardV2.Card.get_card!(card_id)

    if card.title != title do
      PersonalBoardV2.Card.update_card(card, %{title: title})
      update_board_for_subscribers(socket.assigns.current_board.id)
      {:noreply, assign(socket, edit_card_title: 0, lists: current_lists(socket))}
    else
      {:noreply, assign(socket, edit_card_title: 0)}
    end
  end

  def handle_event("archive_card", %{"card_id" => id}, socket) do
    card = PersonalBoardV2.Card.get_card!(id)

    PersonalBoardV2.Repo.transaction(fn ->
      PersonalBoardV2.Card.delete_card(card)
      PersonalBoardV2.Card.reorder_list_after_removing_card(card)
      update_board_for_subscribers(socket.assigns.current_board.id)
    end)

    {:noreply,
     assign(socket, lists: PersonalBoardV2.List.lists_for_board(1), show_card_composer: 0)}
  end

  # For debugging purposes
  def handle_event(event, params, socket) do
    IO.puts(event)
    IO.inspect(params)

    {:noreply, socket}
  end

  def handle_info({__MODULE__, {:update_board, board_id}}, socket) do
    if socket.assigns.current_board.id == board_id do
      {:noreply, assign(socket, lists: current_lists(socket))}
    else
      {:noreply, socket}
    end
  end

  def handle_info({__MODULE__, data}, socket) do
    IO.puts("Not Handled")
    IO.inspect(data)
    {:noreply, socket}
  end

  def boards_to_select(current_board) do
    PersonalBoardV2.Board.list_boards()
    |> Enum.filter(fn board -> board.id != current_board.id end)
  end

  def current_lists(socket) do
    PersonalBoardV2.List.lists_for_board(socket.assigns.current_board.id)
  end
end
