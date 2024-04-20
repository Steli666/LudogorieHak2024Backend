defmodule HakatonBackendWeb.SessionController do
  use HakatonBackendWeb, :controller

  alias HakatonBackend.Authentication.Auth
  alias HakatonBackend.DB.Models.User

  alias HakatonBackendWeb.Utils.Validation

  import HakatonBackendWeb.Responses

  def register(conn, params) do
    with {:ok, %{password: password} = validated_params} <- Validation.validate(&validate_register/1, params),
         {:ok, %User{email: email}} <- User.create(validated_params),
         {:ok, %{token: token}} <- Auth.authenticate(%{email: email, password: password}) do
      success(conn, %{token: token})
    else
      error -> error(conn, error)
    end
  end

  def login(conn, params) do
    with {:ok, validated_params} <- Validation.validate(&validate_login/1, params),
         {:ok, %{token: token, user: _user}} <- Auth.authenticate(validated_params) do
      success(conn, %{token: token})
    else
      error ->
        error(conn, error)
    end
  end

  def refresh_token(%{private: %{guardian_default_token: token}} = conn, _params) do
    case Auth.refresh(token) do
      {:ok, new_token} ->
        success(conn, %{token: new_token})

      {:error, _reason} ->
        error(conn, {:error, :unauthorized})
    end
  end

  # def index_sessions(conn, _params) do
  #   with %User{} = u <- Guardian.Plug.current_resource(conn),
  #        {:ok, %{sessions: sessions}} <- User.get(u.id, sessions: :calculations) do
  #     success(conn, %{sessions: Enum.map(sessions, &session_view/1)})
  #   else
  #     error -> error(conn, error)
  #   end
  # end

  # def show_session(conn, params) do
  #   with {:ok, %{session_id: session_id}} <-
  #          Validation.validate(&validate_show_session/1, params),
  #        %User{} = u <- Guardian.Plug.current_resource(conn),
  #        {:ok, %{sessions: sessions}} <- User.get(u.id, :sessions),
  #        true <- verify_owns_session(sessions, session_id),
  #        {:ok, session} <- Session.get(session_id, :calculations) do
  #     success(conn, session_view(session))
  #   else
  #     false -> error(conn, {:error, :not_found})
  #     error -> error(conn, error)
  #   end
  # end

  defp validate_register(%{"email" => _, "password" => _, "first_name" => _, "last_name" => _}), do: :ok
  defp validate_register(_), do: @bad_request

  defp validate_login(%{"email" => _, "password" => _}), do: :ok
  defp validate_login(_), do: @bad_request

  # defp validate_show_session(%{"session_id" => _}), do: :ok
  # defp validate_show_session(_), do: @bad_request

  # defp verify_owns_session(sessions, session_id) do
  #   Enum.any?(sessions, fn %Session{id: id} -> session_id == id end)
  # end

  # defp session_view(%Session{id: session_id, calculations: calculations}),
  #   do: %{session_id: session_id, calculations: Enum.map(calculations, &calculation_view/1)}

  # defp calculation_view(%Calculation{
  #        type: type,
  #        input: input,
  #        session_id: session_id,
  #        result: result
  #      }) do
  #   %{type: type, input: input, session_id: session_id, result: result}
  # end
end
