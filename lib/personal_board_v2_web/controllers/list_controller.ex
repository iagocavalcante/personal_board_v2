defmodule PersonalBoardV2Web.ListController do
  use PersonalBoardV2Web, :controller

  alias PersonalBoardV2.Actors.List

  def index(conn, _params) do
    lists = PersonalBoardV2.List.list_lists()
    render(conn, "index.html", lists: lists)
  end

  def new(conn, _params) do
    changeset = PersonalBoardV2.List.change_list(%List{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    case PersonalBoardV2.List.create_list(list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: Routes.list_path(conn, :show, list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    list = PersonalBoardV2.List.get_list!(id)
    render(conn, "show.html", list: list)
  end

  def edit(conn, %{"id" => id}) do
    list = PersonalBoardV2.List.get_list!(id)
    changeset = PersonalBoardV2.List.change_list(list)
    render(conn, "edit.html", list: list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = PersonalBoardV2.List.get_list!(id)

    case PersonalBoardV2.List.update_list(list, list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: Routes.list_path(conn, :show, list))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = PersonalBoardV2.List.get_list!(id)
    {:ok, _list} = PersonalBoardV2.List.delete_list(list)

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: Routes.list_path(conn, :index))
  end
end
