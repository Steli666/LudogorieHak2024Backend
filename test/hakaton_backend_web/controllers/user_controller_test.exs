defmodule HakatonBackendWeb.UserControllerTest do
  alias HakatonBackend.DB.Models.UserFriends
  alias HakatonBackend.Constants.FriendRequestStatus
  alias HakatonBackend.DB.Models.FriendRequest
  use HakatonBackendWeb.ConnCase, async: true

  describe "send_friend_request/2" do
    setup do
      {:ok, user} =
        HakatonBackend.DB.Models.User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      %{another_user: user}
    end

    test "successfully send friend request", %{conn_user: conn, another_user: another_user} do
      conn
      |> put("/api/send-friend-request/#{another_user.id}")
      |> response(204)

      assert {:ok, %FriendRequest{}} = FriendRequest.get_by(%{recipient_id: another_user.id})
    end
  end

  describe "accept_friend_request/2" do
    setup %{user: user} do
      {:ok, another_user} =
        HakatonBackend.DB.Models.User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      FriendRequest.create(%{sender_id: another_user.id, recipient_id: user.id})

      %{another_user: another_user}
    end

    test "successfully accept friend request", %{
      conn_user: conn,
      user: user,
      another_user: another_user
    } do
      conn
      |> put("/api/accept-friend-request/#{another_user.id}")
      |> response(204)

      assert {:ok, %FriendRequest{}} =
               FriendRequest.get_by(%{
                 sender_id: another_user.id,
                 status: FriendRequestStatus.accepted()
               })

      assert {:ok, %UserFriends{}} =
               UserFriends.get_by(%{
                 friend_id: another_user.id,
                 user_id: user.id
               })
    end
  end

  describe "refuse_friend_request/2" do
    setup %{user: user} do
      {:ok, another_user} =
        HakatonBackend.DB.Models.User.create(%{
          first_name: "Mark",
          last_name: "Brie",
          email: "markbrie@gmail.com",
          password: "123456",
          username: "mark_brie"
        })

      FriendRequest.create(%{sender_id: another_user.id, recipient_id: user.id})

      %{another_user: another_user}
    end

    test "successfully refuse friend request", %{conn_user: conn, another_user: another_user} do
      conn
      |> put("/api/refuse-friend-request/#{another_user.id}")
      |> response(204)

      assert {:ok, %FriendRequest{}} =
               FriendRequest.get_by(%{
                 sender_id: another_user.id,
                 status: FriendRequestStatus.refused()
               })
    end
  end
end
