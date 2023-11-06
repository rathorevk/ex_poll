defmodule ExPollWeb.ETS.UserAuth do
  @table_name :user_auth

  defstruct [:session_uuid, :token]

  def new do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  def insert(session_uuid, token) do
    :ets.insert_new(@table_name, {:"#{session_uuid}", token})
  end

  def lookup(session_uuid) do
    :ets.lookup(@table_name, :"#{session_uuid}")
  end

  def delete_session(session_uuid) do
    :ets.delete(@table_name, :"#{session_uuid}")
  end
end
