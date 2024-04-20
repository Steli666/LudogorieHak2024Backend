defmodule HakatonBackend.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HakatonBackendWeb.Telemetry,
      HakatonBackend.Repo,
      {DNSCluster, query: Application.get_env(:hakaton_backend, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: HakatonBackend.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: HakatonBackend.Finch},
      # Start a worker by calling: HakatonBackend.Worker.start_link(arg)
      # {HakatonBackend.Worker, arg},
      # Start to serve requests, typically the last entry
      HakatonBackendWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HakatonBackend.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HakatonBackendWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
