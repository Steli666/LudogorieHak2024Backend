defmodule HakatonBackendWeb.ChatControllerTest do
  use HakatonBackendWeb.ConnCase, async: false

  alias HakatonBackend.DB.Models.Message
  alias HakatonBackend.DB.Models.Conversation
  alias HakatonBackend.Constants.FriendRequestStatus
  alias HakatonBackend.DB.Models.FriendRequest
  alias HakatonBackend.DB.Models.UserFriends
  alias HakatonBackend.DB.Models.User

  describe "send_message/2" do
    setup %{user: user} do
      {:ok, another_user} =
        User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      {:ok, _} =
        FriendRequest.create(%{
          sender_id: another_user.id,
          recipient_id: user.id,
          status: FriendRequestStatus.accepted()
        })

      {:ok, _} = UserFriends.create(%{friend_id: another_user.id, user_id: user.id})

      {:ok, _} = Conversation.create(%{sender_id: user.id, recipient_id: another_user.id})
      {:ok, conversation} = Conversation.get_conversation_between_users(user.id, another_user.id)
      %{another_user: another_user, conversation_id: conversation.id}
    end

    test "successfully send a message", %{
      conn_user: conn,
      user: user,
      another_user: friend,
      conversation_id: conversation_id
    } do
      conn
      |> post("/api/conversation/#{conversation_id}/#{friend.id}", %{"content" => "Hello world!"})
      |> response(204)

      assert {:ok, [%Message{}]} =
               Message.get_by_user_conversation(friend.id, user.id, conversation_id)

      assert {:ok, [%Message{}]} =
               Message.get_by_user_conversation(user.id, friend.id, conversation_id)
    end
  end

  describe "index/2" do
    setup %{user: user} do
      {:ok, another_user} =
        User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      {:ok, _} =
        FriendRequest.create(%{
          sender_id: another_user.id,
          recipient_id: user.id,
          status: FriendRequestStatus.accepted()
        })

      {:ok, _} = UserFriends.create(%{friend_id: another_user.id, user_id: user.id})

      {:ok, _} = Conversation.create(%{sender_id: user.id, recipient_id: another_user.id})

      {:ok, another_user} =
        User.create(%{
          first_name: "Sasha",
          last_name: "Spoof",
          email: "asha@gmail.com",
          password: "123456",
          username: "ashiee"
        })

      {:ok, _} =
        FriendRequest.create(%{
          sender_id: another_user.id,
          recipient_id: user.id,
          status: FriendRequestStatus.accepted()
        })

      {:ok, _} = UserFriends.create(%{friend_id: another_user.id, user_id: user.id})

      {:ok, _} = Conversation.create(%{sender_id: user.id, recipient_id: another_user.id})

      %{}
    end

    test "successfully list conversations", %{conn_user: conn} do
      response =
        conn
        |> get("/api/conversation")
        |> json_response(200)

      assert %{"conversations" => [%{}, %{}]} = response
    end
  end

  describe "show/2" do
    setup %{user: user} do
      {:ok, another_user} =
        User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      {:ok, _} =
        FriendRequest.create(%{
          sender_id: another_user.id,
          recipient_id: user.id,
          status: FriendRequestStatus.accepted()
        })

      {:ok, _} = UserFriends.create(%{friend_id: another_user.id, user_id: user.id})

      {:ok, conversation} =
        Conversation.create(%{sender_id: user.id, recipient_id: another_user.id})

      Message.create(%{conversation_id: conversation.id, sender_id: user.id, content: "Hi!"})
      %{conversation_id: conversation.id}
    end

    test "successfully show chat", %{
      conn_user: conn,
      conversation_id: conversation_id
    } do
      response =
        conn
        |> get("/api/conversation/#{conversation_id}")
        |> json_response(200)

      assert %{"messages" => [%{"content" => "Hi!"}]} = response
    end
  end
end
