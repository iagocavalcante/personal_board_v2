defmodule PersonalBoardV2Web.AddBoardForm do
  @moduledoc """
  LiveView Component to display a form for create board.
  """
  use PersonalBoardV2Web, :live_component

  def mount(_session, socket) do
    IO.inspect(connected?(socket), label: "CONNTECTION STATUS")
    {:ok, assign(socket, :board, %{})}
  end

  def handle_event("add_board", %{"board" => %{"title" => title, "user_id" => user_id}}, socket) do
    case PersonalBoardV2.Board.create_board(%{"title" => title, "user_id" => user_id}) do
      {:ok, _board} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Quadro salvo com sucesso."))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, error} ->
        IO.inspect(error.errors)
    end
  end
end
