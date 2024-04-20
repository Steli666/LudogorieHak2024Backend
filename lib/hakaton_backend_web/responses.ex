defmodule HakatonBackendWeb.Responses do
  alias Plug.Conn
  alias Phoenix.Controller

  @default_fail_msg "The requested action has failed."

  def success(conn, payload)

  def success(%Plug.Conn{} = conn, payload) do
    conn
    |> Conn.put_status(200)
    |> Controller.json(payload)
  end

  def success_create(%Plug.Conn{} = conn, payload) do
    conn
    |> Conn.put_status(201)
    |> Controller.json(payload)
  end

  def success_empty(conn) do
    conn
    |> Conn.put_status(204)
    |> Controller.text("")
  end

  def error(conn, {:error, :bad_request}) do
    bad_request(conn, @default_fail_msg)
  end

  def error(conn, {:error, :bad_request, reason}) do
    bad_request(conn, @default_fail_msg, reason)
  end

  def error(conn, {:error, :unauthorized}) do
    unauthorized(conn, @default_fail_msg)
  end

  def error(conn, {:error, :unauthorized, reason}) do
    unauthorized(conn, @default_fail_msg, reason)
  end

  def error(conn, {:error, :forbidden}) do
    forbidden(conn, @default_fail_msg)
  end

  def error(conn, {:error, :not_found}) do
    not_found(conn, @default_fail_msg)
  end

  def error(conn, {:error, :not_found, reason}) do
    not_found(conn, @default_fail_msg, reason)
  end

  defp unauthorized(
         conn,
         message,
         reason \\ "Authentication credentials were missing or incorrect."
       ) do
    conn
    |> Conn.put_status(401)
    |> error_response(message, reason)
  end

  defp forbidden(conn, message, reason \\ "No access rights to fullfil the requested action.") do
    conn
    |> Conn.put_status(403)
    |> error_response(message, reason)
  end

  defp bad_request(conn, message, reason \\ "Malformed request syntax.") do
    conn
    |> Conn.put_status(400)
    |> error_response(message, reason)
  end

  defp not_found(conn, message, reason \\ "The resource could not be found.") do
    conn
    |> Conn.put_status(404)
    |> error_response(message, reason)
  end

  defp error_response(conn, message, reason) do
    error = %{
      message: String.replace(message, "_", " "),
      reason: reason
    }

    Controller.json(conn, error)
  end
end
