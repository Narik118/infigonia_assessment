defmodule InfigoniaAssessment.Repo.Migrations.RevenueWithRate do
  use Ecto.Migration

  def change do
    create table(:revenue, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :revenue, :float
      add :currency, :string
      add :rate, :float
      add :revenue_adjusted, :float
      add :source, :string
      add :date, :utc_datetime, null: false

      timestamps(type: :utc_datetime_usec)
    end

    create index(:revenue, [:currency])
  end
end
