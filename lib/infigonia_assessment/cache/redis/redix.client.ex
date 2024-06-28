defmodule InfigoniaAssessment.Cache.Redis.RedixClient do

  # refactore this to dynamicallly pick reids pool
  def set_key_in_cache(key, value), do: Redix.command(:redix_0, ["SET", key, value])

  def get_value_from_cache(key), do: Redix.command(:redix_0, ["GET", key])

  def set_lock(), do: Redix.command(:redix_0, ["SET", "revenue_table_lock", "locked", "NX", "EX", 30])

  def realse_lock(), do: Redix.command(:redix_0, ["DEL", "revenue_table_lock"])
end
