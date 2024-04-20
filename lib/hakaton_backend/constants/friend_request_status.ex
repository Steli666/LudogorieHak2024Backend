defmodule HakatonBackend.Constants.FriendRequestStatus do
  @types ["pending", "refused", "accepted"]

  def types do
    @types
  end

  def pending, do: "pending"
  def refused, do: "refused"
  def accepted, do: "accepted"
end
