defmodule HakatonBackendWeb.ChatController do
  use HakatonBackendWeb, :controller

  alias HakatonBackend.DB.Models.Conversation
  alias HakatonBackend.DB.Models.Message
  alias HakatonBackend.DB.Models.User

  def index(conn, _params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, conversations} <- Conversation.get_all_by_user_id(user.id),
         parsed_conversations <-
           Enum.map(conversations, &conversation_view(&1, user.id)) do
      success(conn, %{conversations: parsed_conversations})
    else
      error ->
        error(conn, error)
    end
  end

  def show(conn, params) do
    with {:ok, %{conversation_id: conversation_id}} <-
           Validation.validate(&validate_show/1, params),
         {:ok, messages} <- Message.get_all_by(%{conversation_id: conversation_id}),
         parsed_messages <- Enum.map(messages, &message_view/1) do
      success(conn, %{messages: parsed_messages})
    else
      error ->
        error(conn, error)
    end
  end

  def send_message(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{friend_id: friend_id, content: content}} <-
           Validation.validate(&validate_send_messages/1, params),
         {:ok, conversation} <- Conversation.get_conversation_between_users(user.id, friend_id),
         {:ok, message} <-
           Message.create(%{
             sender_id: user.id,
             content: content,
             conversation_id: conversation.id,
             date: DateTime.utc_now()
           }),
         {:ok, _} <- Conversation.update(conversation.id, %{last_message_id: message.id}) do
      success_empty(conn)
    else
      error ->
        error(conn, error)
    end
  end

  defp validate_send_messages(%{"friend_id" => _, "conversation_id" => _, "content" => _}),
    do: :ok

  defp validate_send_messages(_), do: @bad_request

  defp validate_show(%{"conversation_id" => _}), do: :ok
  defp validate_show(_), do: @bad_request

  defp conversation_view(
         %Conversation{
           id: id,
           recipient_id: friend_id,
           last_message_id: msg_id,
           updated_at: updated_at
         },
         current_user
       )
       when friend_id != current_user do
    last_message =
      case msg_id do
        nil ->
          ""

        msg_id ->
          {:ok, %{content: last_message}} = Message.get(msg_id)

          last_message
      end

    {:ok, %User{username: username}} = User.get(friend_id)
    %{id: id, recipient_username: username, last_message: last_message, updated_at: updated_at}
  end

  defp conversation_view(
         %Conversation{
           id: id,
           sender_id: friend_id,
           last_message_id: msg_id,
           updated_at: updated_at
         },
         _
       ) do
    {:ok, %Message{content: last_message}} = Message.get(msg_id)
    {:ok, %User{username: username}} = User.get(friend_id)
    %{id: id, recipient_username: username, last_message: last_message, updated_at: updated_at}
  end

  defp message_view(%Message{
         sender_id: sender_id,
         date: date,
         content: content
       }) do
    %{
      sender_id: sender_id,
      date: date,
      content: content
    }
  end
end
