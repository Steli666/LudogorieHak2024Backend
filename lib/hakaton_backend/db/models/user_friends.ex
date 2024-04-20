defmodule HakatonBackend.DB.Models.UserFriends do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.User

  schema "user_friends" do
    belongs_to(:user, User)
    belongs_to(:friend, User)

    timestamps()
  end

  def changeset(user_event, attrs) do
    user_event
    |> cast(attrs, [:user_id, :friend_id])
    |> validate_required([:user_id, :friend_id])
  end
end
