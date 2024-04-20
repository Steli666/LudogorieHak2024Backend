defmodule HakatonBackend.Repo.Migrations.CreateUsersInterestsTable do
  use Ecto.Migration

  def change do
    create table("users_interests") do
      add :user_id, references(:users, on_delete: :delete_all)
      add :interest_id, references(:interests, on_delete: :delete_all)

      timestamps()
    end

    create unique_index(:users_interests, [:user_id, :interest_id])
  end
end
