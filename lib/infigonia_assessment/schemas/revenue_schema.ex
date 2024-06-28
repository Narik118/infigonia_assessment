defmodule InfigoniaAssessment.Schemas.RevenueSchema do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "revenue" do
    field :revenue, :float
    field :currency, :string
    field :rate, :float
    field :revenue_adjusted, :float
    field :source, :string
    field :date, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(revenue, attrs) do
    revenue
    |> cast(attrs, [:revenue, :currency, :rate, :revenue_adjusted, :date])
    |> validate_required([:revenue, :currency, :rate, :revenue_adjusted, :date])
  end
end
