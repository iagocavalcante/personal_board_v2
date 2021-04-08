defmodule PersonalBoardV2Web.AddListForm do
  @moduledoc """
  LiveView Component to display a form for create board.
  """
  use PersonalBoardV2Web, :live_component

  def mount(_session, socket) do
    {:ok, assign(socket, :list)}
  end

  def handle_event("add_list", %{"list" => %{"title" => title, "board_id" => board_id}}, socket) do
    case PersonalBoardV2.List.create_list(%{"title" => title, "board_id" => board_id}) do
      {:ok, _ist} ->
        {:noreply,
         socket
         |> put_flash(:info, gettext("Lista salva com sucesso."))
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, error} ->
        IO.inspect(error.errors)
    end
  end
end
