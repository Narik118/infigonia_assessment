defmodule InfigoniaAssessment.Cache.Redis.ApiToConfig do

  def get_caching_service, do: Keyword.fetch!(config(), :caching_pool_sup)

  def get_caching_client, do: Keyword.fetch!(config(), :caching_client)

  def get_pool_size, do: Keyword.fetch!(config(), :pool_size)

  def get_host, do: "localhost"

  def get_port, do: String.to_integer("6379")

  defp config, do: Application.get_env(:ludo, __MODULE__, [])

end
