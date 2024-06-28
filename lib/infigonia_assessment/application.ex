defmodule InfigoniaAssessment.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      InfigoniaAssessmentWeb.Telemetry,
      # Start the Ecto repository
      InfigoniaAssessment.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: InfigoniaAssessment.PubSub},
      # Start Finch
      {Finch, name: InfigoniaAssessment.Finch},
      # Start the Endpoint (http/https)
      InfigoniaAssessmentWeb.Endpoint,
      InfigoniaAssessment.Cache.Redis.RedisSupervisor,
      # caching_service,
      # Start a worker by calling: InfigoniaAssessment.Worker.start_link(arg)
      # {InfigoniaAssessment.Worker, arg}
      InfigoniaAssessment.Quantum.Sheduler,
      InfigoniaAssessment.CsvFetcher.CsvFetcherSupervisor,
      InfigoniaAssessment.ExchangeRates.RatesSupervisor,
      InfigoniaAssessment.Revenue.RevenueSupervisor,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: InfigoniaAssessment.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    InfigoniaAssessmentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
