defmodule HakatonBackend.Repo.Migrations.CreateLocationTable do
  use Ecto.Migration

  def change do
    create table("locations") do
      add :latitude, :float, null: true
      add :longitude, :float, null: true
      add :name, :string, null: true
      add :additional_information, :string, null: true
      add :is_online, :boolean, null: false
      add :event_id, references(:events, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
