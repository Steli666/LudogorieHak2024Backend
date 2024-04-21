defmodule HakatonBackendWeb.EventController do
  alias HakatonBackend.DB.Models.Location
  use HakatonBackendWeb, :controller

  alias HakatonBackend.DB.Models.Event

  def index(conn, _params) do
    with {:ok, active_events} <- Event.get_active(),
         parsed_events <- Enum.map(active_events, &event_view/1) do
      success(conn, %{events: parsed_events})
    end
  end

  def show(conn, params) do
    with {:ok, %{event_id: event_id}} <- Validation.validate(&validate_show/1, params),
         {:ok, event} <- Event.get(event_id),
         event <- event_view(event) do
      success(conn, event)
    end
  end

  def create(conn, params) do
    user = Guardian.Plug.current_resource(conn)

    with {:ok, %{name: name, time: time, location: location_name}} <-
           Validation.validate(&validate_create/1, params),
         {:ok, parsed_time} <- DateTime.from_iso8601(time),
         {:ok, event} <- Event.create(%{name: name, time: parsed_time, organizer_id: user.id}),
         {:ok, _} <- Location.create(%{event_id: event.id, is_online: false, name: location_name}) do
      success(conn, event_view(event |> Repo.preload(:location)))
    end
  end

  def validate_show(%{"event_id" => _}), do: :ok
  def validate_show(_), do: @bad_request

  def validate_create(%{"name" => _, "time" => _, "location" => _}), do: :ok
  def validate_create(_), do: @bad_request

  def event_view(%Event{
        id: id,
        name: name,
        time: time,
        description: description,
        location: %{name: location_name}
      }) do
    %{id: id, name: name, time: time, description: description, location: location_name}
  end
end
