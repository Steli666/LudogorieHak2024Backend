defmodule HakatonBackend.Authentication.Tokenizer do
  @moduledoc false
  use Guardian, otp_app: :hakaton_backend

  alias HakatonBackend.DB.Models.User

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def subject_for_token(%User{email: email}, _), do: {:ok, email}
  def subject_for_token(_, _), do: {:error, :resource_not_supported}

  def resource_from_claims(%{"sub" => email}) do
    with {:ok, user} <- User.get_by(:email, email) do
      {:ok, user}
    end
  end
end
