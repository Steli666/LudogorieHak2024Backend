defmodule HakatonBackend.DB.Models.UsersInterests do
  @moduledoc false
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.User
  alias HakatonBackend.DB.Models.Interest

  @primary_key false
  schema "users_interests" do
    belongs_to :user, User
    belongs_to :event, Interest

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:user_id, :interest_id])
    |> validate_required([:user_id, :interest_id])
    |> unique_constraint(:user_id, name: :user_events_user_id_interest_id_index)
  end
end
