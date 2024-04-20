defmodule HakatonBackend.Repo do
  use Ecto.Repo,
    otp_app: :hakaton_backend,
    adapter: Ecto.Adapters.Postgres
end
