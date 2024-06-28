defmodule InfigoniaAssessment.Revenue.RevenueProcessor do
  use GenServer

  require Logger

  import File
  import CSV
  import Ecto.Query

  alias InfigoniaAssessment.Repo, as: Repo
  alias InfigoniaAssessment.CsvFetcher.CsvDataEndpoints
  alias InfigoniaAssessment.Schemas.ExchangeRateSchema
  alias InfigoniaAssessment.Schemas.RevenueSchema
  alias InfigoniaAssessment.Cache.Redis.RedixClient

  def start_link(file_name) do
    GenServer.start_link(__MODULE__, file_name, name: {:via, Swarm, file_name})
  end

  def init(file_name) do
    parse_write_csv(file_name)
    {:ok, file_name}
  end

  @impl true
  def handle_cast({:terminate_process}, file_name) do
    Logger.info("Terminating #{file_name} process.")
    {:stop, :normal, file_name}
  end

  @impl true
  def handle_info({:parse_write_csv, file_name}, state) do
    parse_write_csv(file_name)
    {:noreply, state}
  end

  def parse_write_csv(file_name) do
    case acquire_lock() do
      {:ok, true} ->
    parsed_csv = CsvDataEndpoints.parse_csv(file_name)
    transformed_csv = calculate_revenue_times_rate(parsed_csv, file_name)

        Ecto.Multi.new()
        |> insert_transformed_data(transformed_csv)
        |> Repo.transaction()

        case release_lock() do
          {:ok, :released} ->
            GenServer.cast(self(), {:terminate_process})
          {:error, :locked} ->
            Logger.debug("Failed to realse lock on the process #{file_name}")
        end


      {:error, :locked} ->
        Process.send_after(self(), {:parse_write_csv, file_name}, 2000)

    end
  end

  defp insert_transformed_data(multi, transformed_data) do
    Enum.reduce(transformed_data, multi, fn %{currency: currency, rate: rate, revenue_times_rate: revenue_times_rate} = data, acc ->
      operation_name = :"insert_#{currency}_#{DateTime.utc_now()}" # Append a unique identifier

      Ecto.Multi.insert(acc, operation_name, RevenueSchema.changeset(%RevenueSchema{}, %{
        currency: currency,
        rate: rate,
        revenue: data.revenue,
        revenue_adjusted: revenue_times_rate,
        source: data.source,
        date: data.date
      }))
    end)
  end

  def calculate_revenue_times_rate(parsed_csv, file_name) do
    currency_rates_to_fetch = Enum.uniq(Enum.map(parsed_csv, &(&1.currency)))
    rates = get_rates(currency_rates_to_fetch)

    parsed_csv
    |> Enum.map(fn %{date: date, currency: currency, revenue: revenue} ->
      rate = rates
             |> Enum.find(&(&1.currency_code == currency))
             |> Map.get(:rate)  # Default to 1.0 if rate is not found
      revenue_times_rate = revenue * rate
      %{date: DateTime.utc_now(), currency: currency, revenue: revenue, rate: rate, revenue_times_rate: revenue_times_rate, master_currency: "USD", source: file_name}
    end)
  end


  defp get_rates(currency_rates_to_fetch) do
    rates_query =
      from(er in ExchangeRateSchema,
        where: er.currency_code in ^currency_rates_to_fetch,
        select: %{currency_code: er.currency_code, rate: er.rate}
      )

    Repo.all(rates_query)
  end

  defp acquire_lock() do
    case RedixClient.set_lock() do
      {:ok, "OK"} ->
        {:ok, true}
      {:ok, nil} ->
        {:error, :locked}
    end
  end

  defp release_lock() do
    case RedixClient.realse_lock() do
      {:ok, 1} ->
        {:ok, :released}
      {:ok, 0} ->
        {:error, :locked}
    end
  end
end
