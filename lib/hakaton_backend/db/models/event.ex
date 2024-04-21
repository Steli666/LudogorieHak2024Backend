defmodule HakatonBackend.DB.Models.Event do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.Location
  alias HakatonBackend.DB.Models.User
  alias HakatonBackend.DB.Models.UsersEvents

  schema "events" do
    field(:name, :string)
    field(:time, :utc_datetime)
    field(:description, :string)

    has_one(:location, Location)
    belongs_to(:organizer, User)
    many_to_many(:attendees, User, join_through: UsersEvents)

    timestamps()
  end

  @required_attrs [:name, :time, :organizer_id]
  @allowed_attrs @required_attrs

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
  end

  def get_active do
    now = DateTime.utc_now()

    from(e in __MODULE__,
      where: e.time > ^now,
      select: e
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
