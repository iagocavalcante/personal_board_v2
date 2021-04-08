defmodule PersonalBoardV2.Repo.Migrations.AddRelationshipBoardUser do
  use Ecto.Migration

  def change do
    alter table("boards") do
      add(:user_id, references(:users), null: false)
    end
  end
end
