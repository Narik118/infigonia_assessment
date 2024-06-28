defmodule InfigoniaAssessment.CsvFetcher.CsvFetcherSupervisor do
  use DynamicSupervisor

  require Logger
  alias InfigoniaAssessment.CsvFetcher.CsvFetcher
  alias InfigoniaAssessment.CsvFetcher.CsvDataEndpoints

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl true
  def init(_opts) do
    Logger.info("Initialising CsvFetcherSupervisor Supervisor.")
    # Process.spawn(__MODULE__, :start_childs, [[]], [])
    DynamicSupervisor.init(strategy: :one_for_one, max_restarts: 100, max_seconds: 5)
  end

  def start_childs(opts) do
    endpoints_list = CsvDataEndpoints.api_endpoints()

    Enum.each(endpoints_list, fn endpoint ->
      spec = %{
        id: endpoint,
        start: {CsvFetcher, :start_link, [endpoint]},
        restart: :temporary
      }

      DynamicSupervisor.start_child(__MODULE__, spec)
    end)
  end
end
