defmodule PersonalBoardV2Web.BoardsLive do
  use PersonalBoardV2Web, :live_view

  @topic "board_updates"

  @impl true
  def render(assigns) do
    PersonalBoardV2Web.BoardView.render("board.html", assigns)
  end

  @impl true
  def mount(_params, %{"current_user" => current_user} = _session, socket) do
    Phoenix.PubSub.subscribe(PersonalBoardV2.PubSub, @topic)

    current_board = PersonalBoardV2.Board.get_board!(current_user.id)

    if current_board do
      lists = PersonalBoardV2.List.lists_for_board(current_board.id)
    else
      lists = []
    end

    {:ok,
     assign(socket,
       lists:
         if(current_board, do: PersonalBoardV2.List.lists_for_board(current_board.id), else: []),
       current_board: current_board,
       current_user: current_user,
       boards: if(current_board, do: boards_to_select(current_board, current_user.id), else: []),
       show_list_actions: false,
       edit_list_title: 0,
       edit_card_title: 0
     )}
  end

  @impl true
  def handle_params(params, url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params, url)}
  end

  defp apply_action(socket, :new_list, params, url) do
    board_id = params |> Map.get("board_id")
    uri = URI.parse(url)

    socket
    |> assign(:page_title, gettext("Nova lista"))
    |> assign(:list, %PersonalBoardV2.Actors.List{})
    |> assign(:url, uri)
    |> assign(:board_id, board_id)
  end

  defp apply_action(socket, :new_card, params, url) do
    list_id = params |> Map.get("list_id")
    uri = URI.parse(url)

    socket
    |> assign(:page_title, gettext("Novo Card"))
    |> assign(:card, %PersonalBoardV2.Actors.Card{})
    |> assign(:url, uri)
    |> assign(:list_id, list_id)
  end

  defp apply_action(socket, :new, _params, url) do
    uri = URI.parse(url)

    socket
    |> assign(:page_title, gettext("Novo Quadro"))
    |> assign(:board, %PersonalBoardV2.Actors.Board{})
    |> assign(:url, uri)
  end

  defp apply_action(socket, :index, _params, url) do
    uri = URI.parse(url)

    socket
    |> assign(:page_title, gettext("Quadros"))
    |> assign(:board, nil)
    |> assign(:url, uri)
  end

  defp apply_action(socket, nil, _params, url) do
    uri = URI.parse(url)

    socket
    |> assign(:page_title, gettext("Quadros"))
    |> assign(:board, nil)
    |> assign(:url, uri)
  end

  def update_board_for_subscribers(board_id) do
    Phoenix.PubSub.broadcast_from!(
      PersonalBoardV2.PubSub,
      self(),
      @topic,
      {__MODULE__, {:update_board, board_id}}
    )
  end

  def handle_event("set_current_board", %{"board_id" => id, "user_id" => user_id}, socket) do
    board = PersonalBoardV2.Board.get_board_by_id!(id, user_id)
    lists = PersonalBoardV2.List.lists_for_board(board.id)

    {:noreply,
     assign(socket,
       current_board: board,
       boards: boards_to_select(board, user_id),
       lists: lists
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

  def handle_event("show_list_actions", %{"should_show" => "false"}, socket) do
    {:noreply, assign(socket, show_list_actions: false)}
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
     assign(socket,
       lists: PersonalBoardV2.List.lists_for_board(@socket.assigns.current_board.id),
       show_card_composer: 0
     )}
  end

  # For debugging purposes
  def handle_event(event, params, socket) do
    IO.puts(event)
    IO.inspect(params)

    {:noreply, socket}
  end

  @impl true
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

  def boards_to_select(current_board, user_id) do
    PersonalBoardV2.Board.list_boards(user_id)
    |> Enum.filter(fn board -> board.id != current_board.id end)
  end

  def current_lists(socket) do
    PersonalBoardV2.List.lists_for_board(socket.assigns.current_board.id)
  end
end
