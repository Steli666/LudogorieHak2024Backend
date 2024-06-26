defmodule HakatonBackend.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def change do
    create table("users") do
      add :first_name, :string, null: false
      add :last_name, :string, null: false
      add :email, :string, null: false
      add :username, :string, null: false
      add :password, :string, null: false
      add :profile_description, :string, null: true
      add :interests, references(:interests, on_delete: :nothing), null: true

      timestamps()
    end

    create(unique_index(:users, [:email]))
    create(unique_index(:users, [:username]))
  end
end
