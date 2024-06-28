defmodule InfigoniaAssessment.Revenue.RevenueSupervisor do
  use DynamicSupervisor

  require Logger
  alias InfigoniaAssessment.Revenue.RevenueProcessor

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
    folder = "priv/csv_files"
    {:ok, csv_list} = File.ls(folder)
    if csv_list do
      Enum.each(csv_list, fn file ->
        file_path = folder <> "/#{file}"
        spec = %{
          id: file,
          start: {RevenueProcessor, :start_link, [file_path]},
          restart: :temporary
        }

        DynamicSupervisor.start_child(__MODULE__, spec)
      end)
    else
      Logger.error("No CSV Files To Process")
    end
end
end
