defmodule InfigoniaAssessment.CsvFetcher.CsvFetcher do
  use GenServer
  import File
  import CSV

  require Logger
  alias InfigoniaAssessment.CsvFetcher.CsvDataEndpoints

  def start_link(url) do
    GenServer.start_link(__MODULE__, url, name: {:via, Swarm, url})
  end

  @impl true
  def init(url) do
    fetch_csv_data(url)
    {:ok, url}
  end

  @impl true
  def handle_cast({:terminate_process}, state) do
    Logger.info("Terminating CsvFetcher process.")
    {:stop, :normal, state}
  end

  defp fetch_csv_data(url) do
    IO.inspect("entering here in fetch")

    try do
      case HTTPoison.get(url) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          download_data(body, url)
          {:ok, body}

        {:ok, %HTTPoison.Response{status_code: code, body: _body}} ->
          {:error, "Unexpected HTTP status: #{code}"}

        {:error, reason} ->
          {:error, "HTTPoison error: #{reason}"}
      end
    rescue
      error ->
        Logger.error(error)
        {:error, "Failed to fetch CSV data: #{inspect(error)}"}
    end
  end

  defp download_data(body, url) do
    %URI{path: path} = URI.parse(url)
    file_path = "/Users/kiransrigiri/Desktop/infigonia_assessment/priv/csv_files#{path}.csv"

    parsed_data =
      body
      |> String.split("\n", trim: true)
      |> Enum.map(&String.trim(&1))

    csv_content =
      parsed_data
      |> Enum.map(fn line ->
        line
        |> String.replace_prefix("\"\"\"", "\"")
        |> String.replace_suffix("\"\"\"", "\"")
        |> String.split("\",\"")
        |> Enum.map(&String.replace(&1, "\"", ""))
        |> Enum.map(&("\"" <> &1 <> "\""))
        |> Enum.join(",")
      end)
      |> Enum.join("\n")

    case File.write(file_path, csv_content) do
      :ok ->
        Logger.debug("CSV data successfully written to inspect(#{file_path})")
        GenServer.cast(self(), {:terminate_process})

      {:error, reason} ->
        Process.send_after(self(), {:restart}, 10000)
        Logger.error("Failed to write CSV data: inspect(#{reason})")
    end
  end
end
