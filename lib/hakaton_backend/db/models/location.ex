defmodule HakatonBackend.DB.Models.Location do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.Event

  schema "locations" do
    field(:name, :string)
    field(:latitude, :float)
    field(:longitude, :float)
    field(:additional_information, :string)
    field(:is_online, :boolean)

    belongs_to(:event, Event)

    timestamps()
  end

  @required_attrs [:is_online, :event_id]
  @allowed_attrs [:name, :latitude, :longitude, :additional_information]

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
  end
end
