defmodule InfigoniaAssessmentWeb.CsvlocalController do
  use InfigoniaAssessmentWeb, :controller

  def get_csv1(conn, _params) do
    file_path1 = "csv_files/dummy1.csv"

    case File.read(file_path1) do
      {:ok, csv_data} ->
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"data1.csv\"")
        |> send_resp(200, csv_data)

      {:error, reason} ->
        conn
        |> send_resp(500, "Error reading CSV file: #{inspect(reason)}")
    end
  end

  def get_csv2(conn, _params) do
    file_path1 = "csv_files/dummy2.csv"

    case File.read(file_path1) do
      {:ok, csv_data} ->
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"data2.csv\"")
        |> send_resp(200, csv_data)

      {:error, reason} ->
        conn
        |> send_resp(500, "Error reading CSV file: #{inspect(reason)}")
    end
  end

  def get_csv3(conn, _params) do
    file_path1 = "csv_files/dummy3.csv"

    case File.read(file_path1) do
      {:ok, csv_data} ->
        conn
        |> put_resp_content_type("text/csv")
        |> put_resp_header("content-disposition", "attachment; filename=\"data3.csv\"")
        |> send_resp(200, csv_data)

      {:error, reason} ->
        conn
        |> send_resp(500, "Error reading CSV file: #{inspect(reason)}")
    end
  end
end
