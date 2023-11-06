defmodule ExPoll.ETS.Users do
  @moduledoc """
  This module handles ets table users related operations/quaries.
  """

  alias ExPoll.Schema.User

  ## ==========================================================================
  ## Types
  ## ==========================================================================

  @type id :: binary()
  @type username :: String.t()

  @table_name :users

  ## ==========================================================================
  ## Public APIs
  ## ==========================================================================

  @spec new() :: table_name when table_name: atom()
  def new do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  @spec insert(%User{}) :: {:ok, %User{}} | {:error, :bad_value}
  def insert(%User{username: username}) do
    id = Ecto.UUID.generate()

    if :ets.insert_new(@table_name, {id, username}),
      do: {:ok, get(id)},
      else: {:error, :bad_value}
  end

  @spec update(%User{}) :: {:ok, %User{}} | {:error, :user_not_found}
  def update(%User{id: id, username: username} = user) do
    case get(id) do
      nil ->
        {:error, :user_not_found}

      _user ->
        :ets.insert(@table_name, {id, username})
        {:ok, user}
    end
  end

  @spec delete(%User{}) :: {:ok, %User{}} | {:error, :user_not_found}
  def delete(%User{id: id} = user) do
    case get(id) do
      nil ->
        {:error, :user_not_found}

      _user ->
        :ets.delete(@table_name, id)

        {:ok, user}
    end
  end

  @spec get(id()) :: %User{} | nil
  def get(id) do
    @table_name |> :ets.lookup(id) |> format_response()
  end

  @spec get_by_username(username()) :: %User{} | nil
  def get_by_username(username) do
    @table_name |> :ets.match_object({:_, username}) |> format_response()
  end

  @spec all() :: [%User{}]
  def all do
    @table_name
    |> :ets.match(:"$1")
    |> Enum.map(&format_response/1)
  end

  ## ==========================================================================
  ## Private Functions
  ## ==========================================================================

  defp format_response([] = _result) do
    nil
  end

  defp format_response([{id, username}]) do
    format_response({id, username})
  end

  defp format_response({id, username}) do
    %User{id: id, username: username}
  end
end
