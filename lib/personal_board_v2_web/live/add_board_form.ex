defmodule PersonalBoardV2Web.AddBoardForm do
  @moduledoc """
  LiveView Component to display a form for create board.
  """
  use PersonalBoardV2Web, :live_component
  alias PersonalBoardV2.Board

  def mount(_session, socket) do
    IO.inspect(connected?(socket), label: "CONNTECTION STATUS")
    {:ok, assign(socket, :board, %{})}
  end

  def handle_event("add_board", %{"board" => %{"title" => title}}, socket) do
    IO.inspect(socket)
    case PersonalBoardV2.Board.create_board(%{"title" => title}) do
      {:ok, board} ->
        {:noreply,
           socket
           |> put_flash(:info, gettext("Episódio salvo com sucesso."))
           |> push_redirect(to: socket.assigns.return_to)}

      {:error, error} ->
        IO.inspect(error.errors)
    end
  end
end
