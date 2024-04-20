defmodule HakatonBackend.DB.Models.Conversation do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.User

  schema "conversations" do
    field(:last_message_id, :id)

    belongs_to(:sender, User, foreign_key: :sender_id)
    belongs_to(:recipient, User, foreign_key: :recipient_id)
    timestamps()
  end

  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:sender_id, :recipient_id])
    |> validate_required([:sender_id, :recipient_id])
  end

  def get_all_by_user_id(user_id) do
    from(c in __MODULE__, where: c.sender_id == ^user_id or c.recipient_id == ^user_id, select: c)
    |> Repo.all()
    |> case do
      nil ->
        {:ok, []}

      entries ->
        {:ok, entries}
    end
  end

  def get_conversation_between_users(first_user_id, second_user_id) do
    from(c in __MODULE__,
      where:
        (c.sender_id == ^first_user_id and c.recipient_id == ^second_user_id) or
          (c.sender_id == ^second_user_id and c.recipient_id == ^first_user_id),
      select: c
    )
    |> Repo.one()
    |> case do
      entry when not is_nil(entry) -> {:ok, entry}
      _ -> {:error, :not_found, __MODULE__}
    end
  end
end
