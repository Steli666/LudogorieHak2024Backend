defmodule HakatonBackend.DB.Models.Interest do
  use HakatonBackend.DB.Model

  schema "interests" do
    field(:name, :string)
  end

  def changeset(interest, attrs) do
    interest
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
