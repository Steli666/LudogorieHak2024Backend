defmodule HakatonBackend.Repo.Migrations.CreateFriendRequestsTable do
  use Ecto.Migration

  def change do
    create table(:friend_requests) do
      add :sender_id, references(:users, on_delete: :nothing), null: false
      add :recipient_id, references(:users, on_delete: :nothing), null: false
      add :status, :string, default: "pending", null: false

      timestamps()
    end

    create unique_index(:friend_requests, [:sender_id, :recipient_id])
  end
end
