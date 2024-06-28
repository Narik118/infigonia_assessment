defmodule InfigoniaAssessment.ExchangeRates.RatesSupervisor do
  use Supervisor

  alias InfigoniaAssessment.ExchangeRates.RatesProcessor

  def start_link(_init_arg) do
    Supervisor.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(init_arg) do
    children = [
      %{
        id: RatesProcessor,
        start: {RatesProcessor, :start_link, [init_arg]}
      }
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
