defmodule InfigoniaAssessment.ExchangeRates.RatesProcessor do
  use GenServer
  require Logger

  alias Ecto.Multi, as: Multi
  import Ecto.Query

  alias InfigoniaAssessment.Schemas.ExchangeRateSchema
  alias InfigoniaAssessment.Repo, as: Repo

  # use env varible
  @usd_rates_api "https://open.er-api.com/v6/latest/USD"

  def start_link(args),
    do: GenServer.start_link(__MODULE__, args, name: __MODULE__)

  def init(_opts), do: {:ok, %{}, timer_expire_time(:successful)}

  def handle_info(:timeout, state) do
    timer =
      case fetch_and_update_rates() do
        {:ok, :updated} ->
          timer_expire_time(:successful)

        {:error, :failed} ->
          timer_expire_time(:failed)
      end

    {:noreply, state, timer}
  end

  defp timer_expire_time(:successful) do
    curent_time = DateTime.utc_now()
    next_date = Date.add(Date.utc_today(), 1)
    {:ok, time} = Time.new(0, 0, 5)
    {:ok, execution_datetime} = DateTime.new(next_date, time, curent_time.time_zone)
    DateTime.diff(execution_datetime, curent_time, :second) * 1000
  end

  defp timer_expire_time(:failed), do: 10

  def fetch_and_update_rates do
    try do
      case HTTPoison.get(@usd_rates_api) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          with {:ok, %{"provider" => provider, "rates" => rates}} <- Jason.decode(body),
               {:ok, :successfull} <- update_rates_in_db(rates, provider) do
            {:ok, :updated}
          else
            _error -> {:error, :failed}
          end

        {:ok, %HTTPoison.Response{status_code: code, body: body}} ->
          {:error, "Unexpected response: #{code} - #{body}"}

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, "HTTPoison error: #{reason}"}
      end
    rescue
      error ->
        {:error, "Unexpected error: #{inspect(error)}"}
    end
  end

  # refactore queries on the adapter
  defp update_rates_in_db(rates, provider) do
    currency_codes_list = Map.keys(rates)

    existing_rates_query =
      from(er in ExchangeRateSchema,
        where: er.currency_code in ^currency_codes_list
      )

    existing_rates = Repo.all(existing_rates_query)

    existing_rates_map =
      existing_rates
      |> Enum.into(%{}, &{&1.currency_code, &1})

    multi =
      Enum.reduce(rates, Ecto.Multi.new(), fn {currency_code, rate}, acc ->
        case existing_rates_map[currency_code] do
          nil ->
            changeset =
              ExchangeRateSchema.changeset(%ExchangeRateSchema{}, %{
                currency_code: currency_code,
                rate: rate,
                timestamp: DateTime.utc_now(),
                source: provider
              })

            Ecto.Multi.insert(acc, currency_code, changeset)

          existing_rate ->
            changeset =
              ExchangeRateSchema.changeset(existing_rate, %{
                rate: rate,
                timestamp: DateTime.utc_now(),
                source: provider
              })

            Ecto.Multi.update(acc, currency_code, changeset)
        end
      end)

    Repo.transaction(multi)
    |> case do
      {:ok, _} ->
        {:ok, :successfull}

      {:error, _} ->
        {:error, :failed}
    end
  end
end
