defmodule HakatonBackend.Repo.Migrations.CreateMessagesTable do
  use Ecto.Migration

  def change do
    create table("messages") do
      add :sender_id, references(:users, null: false)
      add :conversation_id, references(:conversations, null: false)
      add :content, :string
      add :date, :utc_datetime

      timestamps()
    end

    create index(:messages, [:sender_id])
    create index(:messages, [:conversation_id])
  end
end
