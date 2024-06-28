defmodule YourApp.Repo.Migrations.CreateExchangeRates do
  use Ecto.Migration

  def change do
    create table(:exchange_rates, primary_key: false) do
      add :currency_code, :string, primary_key: true
      add :rate, :float, null: false
      add :source, :string
      add :timestamp, :utc_datetime, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create unique_index(:exchange_rates, [:currency_code])
  end
end
