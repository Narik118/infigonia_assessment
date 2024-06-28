defmodule InfigoniaAssessment.Schemas.ExchangeRateSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:currency_code, :string, autogenerate: false}

  schema "exchange_rates" do
    field :rate, :float
    field :source, :string
    field :timestamp, :utc_datetime

    timestamps()
  end

  def changeset(exchange_rate, attrs) do
    exchange_rate
    |> cast(attrs, [:currency_code, :rate, :timestamp])
    |> validate_required([:currency_code, :rate, :timestamp])
    |> unique_constraint(:currency_code)
  end
end
