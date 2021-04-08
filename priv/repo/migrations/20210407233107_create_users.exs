defmodule PersonalBoardV2.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :uid, :string
      add :name, :string
      add :avatar, :string

      timestamps()
    end
  end
end
