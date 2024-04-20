defmodule HakatonBackend.DB.Models.UsersEvents do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.User
  alias HakatonBackend.DB.Models.Event

  @primary_key false
  schema "users_events" do
    belongs_to :user, User
    belongs_to :event, Event

    timestamps()
  end

  def changeset(user_event, attrs) do
    user_event
    |> cast(attrs, [:user_id, :event_id])
    |> validate_required([:user_id, :event_id])
    |> unique_constraint(:user_id, name: :user_events_user_id_event_id_index)
  end
end
