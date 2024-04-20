defmodule HakatonBackend.DB.Models.User do
  use HakatonBackend.DB.Model

  alias HakatonBackend.DB.Models.Event
  alias HakatonBackend.DB.Models.UsersEvents

  @required_attrs [:first_name, :last_name, :email, :password, :username]
  @allowed_attrs [:profile_description | @required_attrs]

  schema "users" do
    field(:first_name, :string)
    field(:last_name, :string)
    field(:email, :string)
    field(:password, :string)
    field(:username, :string)
    field(:profile_description, :string)

    has_many(:organized_events, Event, foreign_key: :organizer_id)
    many_to_many(:events, Event, join_through: UsersEvents)

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, @allowed_attrs)
    |> validate_required(@required_attrs)
    |> put_password_hash()
  end

  defp put_password_hash(
         %Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset
       ) do
    put_change(changeset, :password, Bcrypt.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset
end
