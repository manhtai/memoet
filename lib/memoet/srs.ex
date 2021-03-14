defmodule Memoet.SRS do
  @moduledoc """
  SRS service
  """
  alias Memoet.EtsCache

  alias Memoet.SRS.Sm2
  alias Memoet.SRS.{Scheduler, Config}
  alias Memoet.Users.SrsConfig
  alias Memoet.Users

  @spec get_scheduler(String.t()) :: Scheduler.t()
  def get_scheduler(user_id) do
    cache_key = get_cache_key(user_id)
    EtsCache.read_or_cache_default(cache_key, fn -> get_scheduler_from_db(user_id) end)
  end

  @spec set_scheduler(String.t(), SrsConfig.t()) :: :ok
  def set_scheduler(user_id, srs_config) do
    config = struct(Config, Map.from_struct(srs_config))
    scheduler = Sm2.new(config)
    EtsCache.cache(get_cache_key(user_id), scheduler)
  end

  @spec get_cache_key(String.t()) :: String.t()
  defp get_cache_key(user_id) do
    "scheduler_" <> user_id
  end

  @spec get_scheduler_from_db(String.t()) :: Scheduler.t()
  def get_scheduler_from_db(user_id) do
    srs_config = Users.get_srs_config(user_id)
    config = struct(Config, Map.from_struct(srs_config))
    Sm2.new(config)
  end
end