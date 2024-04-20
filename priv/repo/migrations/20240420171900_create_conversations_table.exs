defmodule HakatonBackend.Repo.Migrations.CreateConversationsTable do
  use Ecto.Migration

  def change do
    create table("conversations") do
      add :sender_id, references(:users, null: false)
      add :recipient_id, references(:users, null: false)

      timestamps()
    end

    create unique_index(:conversations, [:sender_id, :recipient_id], name: :sender)
  end
end
