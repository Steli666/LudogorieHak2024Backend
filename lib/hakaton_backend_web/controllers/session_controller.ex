defmodule HakatonBackendWeb.SessionController do
  use HakatonBackendWeb, :controller

  alias HakatonBackend.Authentication.Auth
  alias HakatonBackend.DB.Models.User

  def register(conn, params) do
    with {:ok, %{password: password} = validated_params} <-
           Validation.validate(&validate_register/1, params),
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

  defp validate_register(%{"email" => _, "password" => _, "first_name" => _, "last_name" => _}),
    do: :ok

  defp validate_register(_), do: @bad_request

  defp validate_login(%{"email" => _, "password" => _}), do: :ok
  defp validate_login(_), do: @bad_request
end
