# module to define all the endpoints
defmodule InfigoniaAssessment.CsvFetcher.CsvDataEndpoints do
  NimbleCSV.define(MyParser, separator: ",", escape: "\"")

  #make sure atlest one node is on 4000 port
  # can impove by dynamicallt picking nodes but no need to do it here since we will have 3rd party apis
  def api_endpoints() do
    [
      "http://127.0.0.1:4000/csv1",
      "http://127.0.0.1:4000/csv2",
      "http://127.0.0.1:4000/csv3"
    ]
  end


  # we can pattern match on the file name since file name will be the path after domain in our case
  # this will help to parse the csv of a particular format
  # to parse csv from the endpoint "http://127.0.0.1:4000/csv1"
  def parse_csv("priv/csv_files/csv1.csv" = file_path) do
    file_stream = File.stream!(file_path, read_ahead: 100_000_000)

    parsed_data =
      file_stream
      |> MyParser.parse_stream()
      |> Enum.map(fn [revenue, currency, date] ->
        %{revenue: String.to_float(revenue), currency: currency, date: Date.from_iso8601!(date)}
      end)
  end

  # to parse csv from the endpoint "http://127.0.0.1:4000/csv2"
  def parse_csv("priv/csv_files/csv2.csv" = file_path) do
    file_stream = File.stream!(file_path, read_ahead: 100_000_000)

    parsed_data =
      file_stream
      |> MyParser.parse_stream()
      |> Enum.map(fn [revenue, adjusted_value, real_value, currency, date] ->
        %{revenue: String.to_float(revenue), currency: currency, date: Date.from_iso8601!(date)}
      end)
  end

  # to parse csv from the endpoint "http://127.0.0.1:4000/csv3"
  def parse_csv("priv/csv_files/csv3.csv" = file_path) do
    file_stream = File.stream!(file_path, read_ahead: 100_000_000)

    parsed_data =
      file_stream
      |> MyParser.parse_stream()
      |> Enum.map(fn [revenue, adjusted_value, real_value, profit, currency, date]  ->
        %{revenue: String.to_float(revenue), currency: currency, date: Date.from_iso8601!(date)}
      end)
  end

  def convert_to_stream(data) do
    MyParser.dump_to_stream(data)
  end
end
