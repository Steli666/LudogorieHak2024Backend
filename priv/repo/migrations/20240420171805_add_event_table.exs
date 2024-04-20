defmodule HakatonBackend.Repo.Migrations.AddEventTable do
  use Ecto.Migration

  def change do
    create table("events") do
      add :name, :string, null: false
      add :time, :utc_datetime, null: false
      add :description, :string, null: true
      add :organizer_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create(unique_index("events", [:name]))
  end
end
