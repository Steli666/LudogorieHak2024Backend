defmodule HakatonBackendWeb.UserController do
  alias HakatonBackend.DB.Models.User
  use HakatonBackendWeb, :controller

  alias HakatonBackend.Constants.FriendRequestStatus

  alias HakatonBackend.Repo
  alias HakatonBackend.DB.Models.UserFriends
  alias HakatonBackend.DB.Models.Conversation
  alias HakatonBackend.DB.Models.FriendRequest

  def show(conn, params) do
    with {:ok, %{user_id: user_id}} <-
           Validation.validate(&validate_show/1, params),
         {:ok, user} <- User.get(user_id),
         parsed_user <- user_view(user) do
      success(conn, parsed_user)
    else
      error -> error(conn, error)
    end
  end

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

    Repo.transaction(fn ->
      with {:ok, %{sender_id: request_sender_id}} <-
             Validation.validate(&validate_accept_friend_request/1, params),
           {:ok, friend_request} <-
             FriendRequest.get_by(%{sender_id: request_sender_id, recipient_id: user.id}),
           {:ok, _} <-
             FriendRequest.update(friend_request.id, %{status: FriendRequestStatus.accepted()}),
           {:ok, _} <- UserFriends.create(%{user_id: user.id, friend_id: request_sender_id}),
           {:ok, _} <- Conversation.create(%{sender_id: user.id, recipient_id: request_sender_id}) do
        success_empty(conn)
      else
        error ->
          Repo.rollback(error)
      end
    end)
    |> case do
      {:ok, conn} ->
        conn

      {:error, error} ->
        error(conn, error)
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

  def validate_show(%{"user_id" => _}), do: :ok
  def validate_show(_), do: @bad_request

  def validate_send_friend_request(%{"recipient_id" => _}), do: :ok
  def validate_send_friend_request(_), do: @bad_request

  def validate_accept_friend_request(%{"sender_id" => _}), do: :ok
  def validate_accept_friend_request(_), do: @bad_request

  def validate_refuse_friend_request(%{"sender_id" => _}), do: :ok
  def validate_refuse_friend_request(_), do: @bad_request

  def user_view(%User{
        id: id,
        username: username,
        email: email,
        profile_description: profile_description,
        first_name: first_name,
        last_name: last_name
      }) do
    %{
      id: id,
      username: username,
      email: email,
      profile_description: profile_description,
      first_name: first_name,
      last_name: last_name
    }
  end
end
