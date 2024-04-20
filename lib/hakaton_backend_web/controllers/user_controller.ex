defmodule HakatonBackendWeb.UserController do
  alias HakatonBackend.DB.Models.UserFriends
  use HakatonBackendWeb, :controller

  alias HakatonBackend.Constants.FriendRequestStatus

  alias HakatonBackend.DB.Models.FriendRequest

  def send_friend_request(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{recipient_id: recipient_id}} <-
           Validation.validate(&validate_send_friend_request/1, params),
         {:ok, _} <-
           FriendRequest.create(%{
             sender_id: user.id,
             recipient_id: recipient_id,
             status: FriendRequestStatus.pending()
           }) do
      success_empty(conn)
    else
      error -> error(conn, error)
    end
  end

  def accept_friend_request(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{sender_id: sender_id}} <-
           Validation.validate(&validate_accept_friend_request/1, params),
         {:ok, friend_request} <-
           FriendRequest.get_by(%{sender_id: sender_id, recipient_id: user.id}),
         {:ok, _} <-
           FriendRequest.update(friend_request.id, %{status: FriendRequestStatus.accepted()}),
         {:ok, _} <- UserFriends.create(%{user_id: user.id, friend_id: sender_id}) do
      success_empty(conn)
    else
      error -> error(conn, error)
    end
  end

  def refuse_friend_request(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{sender_id: sender_id}} <-
           Validation.validate(&validate_refuse_friend_request/1, params),
         {:ok, friend_request} <-
           FriendRequest.get_by(%{sender_id: sender_id, recipient_id: user.id}),
         {:ok, _} <-
           FriendRequest.update(friend_request.id, %{status: FriendRequestStatus.refused()}) do
      success_empty(conn)
    else
      error -> error(conn, error)
    end
  end

  def validate_send_friend_request(%{"recipient_id" => _}), do: :ok
  def validate_send_friend_request(_), do: @bad_request

  def validate_accept_friend_request(%{"sender_id" => _}), do: :ok
  def validate_accept_friend_request(_), do: @bad_request

  def validate_refuse_friend_request(%{"sender_id" => _}), do: :ok
  def validate_refuse_friend_request(_), do: @bad_request
end
