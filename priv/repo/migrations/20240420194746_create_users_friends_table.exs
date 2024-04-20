defmodule HakatonBackend.Repo.Migrations.CreateUsersFriendsTable do
  use Ecto.Migration

  def change do
    create table("user_friends") do
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :friend_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:user_friends, [:user_id, :friend_id])
  end
end
