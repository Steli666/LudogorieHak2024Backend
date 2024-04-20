defmodule HakatonBackend.Repo.Migrations.AddInterestsTable do
  use Ecto.Migration

  def change do
    create table("interests") do
      add :name, :string, null: false
    end
  end
end
