defmodule HakatonBackend.DB.Models.FriendRequest do
  use HakatonBackend.DB.Model

  alias HakatonBackend.Constants.FriendRequestStatus
  alias HakatonBackend.DB.Models.User

  schema "friend_requests" do
    belongs_to :sender, User
    belongs_to :recipient, User
    field :status, :string, default: "pending"

    timestamps()
  end

  @required_attrs [:sender_id, :recipient_id]
  @allowed_attributes [:status | @required_attrs]

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @allowed_attributes)
    |> validate_required(@required_attrs)
    |> validate_inclusion(:status, FriendRequestStatus.types())
    |> unique_constraint(:sender_id, name: :friend_requests_sender_id_recipient_id_index)
  end
end
