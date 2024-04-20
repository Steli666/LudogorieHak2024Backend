defmodule HakatonBackend.Authentication.Auth do
  @moduledoc false

  alias HakatonBackend.Authentication.Tokenizer
  alias HakatonBackend.DB.Models.User

  def authenticate(%{password: password, email: email}) do
    with {:ok, %User{} = user} <- User.get_by(:email, email),
         {:ok, :valid_credentials} <- validate_password(user, password),
         {:ok, token, _claims} <- Tokenizer.encode_and_sign(user, %{id: user.id}) do
      {:ok, %{user: user, token: token}}
    else
      {:error, :account_not_verified} ->
        {:error, :unauthorized, "Account is not verified."}

      _err ->
        {:error, :unauthorized, "Email or password is incorrect."}
    end
  end

  def refresh(token) do
    case Tokenizer.refresh(token) do
      {:ok, _, {new_token, _new_claims}} -> {:ok, new_token}
      {:error, _reason} = err -> err
    end
  end

  defp validate_password(%User{password: user_password}, password) do
    if Bcrypt.verify_pass(password, user_password) do
      {:ok, :valid_credentials}
    else
      {:error, :invalid_credentials}
    end
  end
end
