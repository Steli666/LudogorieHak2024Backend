defmodule HakatonBackend.Repo.Migrations.CreateUsersEventsTable do
  use Ecto.Migration

  def change do
    create table("users_events") do
      add :user_id, references(:users, on_delete: :delete_all)
      add :event_id, references(:events, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users_events, [:user_id, :event_id])
  end
end
