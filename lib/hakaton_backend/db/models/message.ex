defmodule HakatonBackend.DB.Models.Message do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.User
  alias HakatonBackend.DB.Models.Conversation

  schema "messages" do
    field(:content, :string)
    field(:date, :utc_datetime)

    belongs_to(:sender, User)
    belongs_to(:conversation, Conversation)

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:sender_id, :conversation_id, :content, :date])
    |> validate_required([:sender_id, :conversation_id, :content])
    |> validate_length(:content, min: 1)
  end

  def get_by_user_conversation(first_user_id, second_user_id, conversation_id) do
    from(m in __MODULE__,
      join: c in Conversation,
      on: m.conversation_id == c.id,
      where:
        (c.id == ^conversation_id and
           (m.sender_id == ^first_user_id and c.recipient_id == ^second_user_id)) or
          (c.sender_id == ^second_user_id and c.recipient_id == ^first_user_id)
    )
    |> Repo.all()
    |> case do
      nil ->
        {:ok, []}

      entries ->
        {:ok, entries}
    end
  end
end
