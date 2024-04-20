# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :hakaton_backend,
  ecto_repos: [HakatonBackend.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :hakaton_backend, HakatonBackendWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: HakatonBackendWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: HakatonBackend.PubSub,
  live_view: [signing_salt: "aWmOpGnX"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.

config :hakaton, HakatonBackend.Authentication.Tokenizer,
  issuer: "hakaton",
  secret_key: "OH+s9QEzQ4V5lJk7t1XHbfwxqg41oKCV/nAREVpyzmLWh6R+ujXQE+EO9QzgVM2k"

config :guardian, Guardian.DB,
  repo: HakatonBackend.Repo,
  schema_name: "guardian_tokens",
  sweep_interval: 10

# config :hakaton_backend, HakatonBackend.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
