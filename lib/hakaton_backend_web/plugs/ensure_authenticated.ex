defmodule HakatonBackendWeb.Plug.EnsureAuthenticated do
  @moduledoc false
  use Guardian.Plug.Pipeline,
    otp_app: :hakaton_backend,
    module: HakatonBackend.Authentication.Tokenizer,
    error_handler: HakatonBackend.Authentication.ErrorHandler

  plug(Guardian.Plug.VerifyHeader, scheme: "Bearer", claims: %{"typ" => "access"})
  plug(Guardian.Plug.EnsureAuthenticated)
  plug(Guardian.Plug.LoadResource)
end
