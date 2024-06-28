defmodule InfigoniaAssessment.Repo do
  use Ecto.Repo,
    otp_app: :infigonia_assessment,
    adapter: Ecto.Adapters.Postgres
end
