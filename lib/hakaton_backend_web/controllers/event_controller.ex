defmodule HakatonBackendWeb.EventController do
  use HakatonBackendWeb, :controller

  alias HakatonBackend.DB.Models.Event
  alias HakatonBackend.DB.Models.User
  alias HakatonBackend.DB.Models.UsersEvents
  alias HakatonBackend.DB.Models.Location

  def index(conn, _params) do
    with {:ok, active_events} <- Event.get_active(),
         parsed_events <- Enum.map(active_events, &event_view/1) do
      success(conn, %{events: parsed_events})
    else
      error -> error(conn, error)
    end
  end

  def show(conn, params) do
    with {:ok, %{event_id: event_id}} <- Validation.validate(&validate_show/1, params),
         {:ok, event} <- Event.get(event_id),
         event <- event_view(event) do
      success(conn, event)
    else
      error -> error(conn, error)
    end
  end

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{name: name, time: time, location: location_name}} <-
           Validation.validate(&validate_create/1, params),
         {:ok, parsed_time, _} <- DateTime.from_iso8601(time),
         {:ok, event} <- Event.create(%{name: name, time: parsed_time, organizer_id: user.id}),
         {:ok, _} <- Location.create(%{event_id: event.id, is_online: false, name: location_name}) do
      success(conn, event_view(HakatonBackend.Repo.preload(event, :location)))
    end
  end

  def attend(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{event_id: event_id}} <- Validation.validate(&validate_attend/1, params),
         {:ok, _} <- UsersEvents.create(%{event_id: event_id, user_id: user.id}) do
      success_empty(conn)
    else
      error -> error(conn, error)
    end
  end

  def event_attendees(conn, params) do
    with {:ok, %{event_id: event_id}} <- Validation.validate(&validate_attend/1, params),
         {:ok, event_users} <- UsersEvents.get_all_by(%{event_id: event_id}) do
      parsed_users =
        Enum.map(event_users, fn %{user_id: user_id} ->
          {:ok, user} = User.get(user_id)
          user_view(user)
        end)

      success(conn, %{event_id: event_id, attendees: parsed_users})
    else
      error -> error(conn, error)
    end
  end

  def validate_show(%{"event_id" => _}), do: :ok
  def validate_show(_), do: @bad_request

  def validate_create(%{"name" => _, "time" => _, "location" => _}), do: :ok
  def validate_create(_), do: @bad_request

  def validate_attend(%{"event_id" => _}), do: :ok
  def validate_attend(_), do: @bad_request

  def validate_event_attendees(%{"event_id" => _}), do: :ok
  def validate_event_attendees(_), do: @bad_request

  def event_view(%Event{
        id: id,
        name: name,
        time: time,
        description: description,
        location: %{name: location_name}
      }) do
    %{id: id, name: name, time: time, description: description, location: location_name}
  end

  def user_view(%User{
        id: id,
        username: username,
        first_name: first_name,
        last_name: last_name
      }) do
    %{
      id: id,
      username: username,
      first_name: first_name,
      last_name: last_name
    }
  end
end
