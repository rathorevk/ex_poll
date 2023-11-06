defmodule ExPoll.ETS.Polls.Votes do
  @moduledoc """
  This module handles ets table votes related operations/quaries.
  """

  alias ExPoll.Schema.Poll.Vote

  ## ==========================================================================
  ## Types
  ## ==========================================================================

  @type id :: binary()
  @type user_id :: Users.id()

  @table_name :votes

  ## ==========================================================================
  ## Public APIs
  ## ==========================================================================

  @spec new :: table_name when table_name: atom()
  def new do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  @spec insert(%Vote{}) :: {:ok, %Vote{}} | {:error, :bad_value}
  def insert(%Vote{user_id: user_id, poll_id: poll_id, option_id: option_id} = vote) do
    id = Ecto.UUID.generate()

    case :ets.insert_new(@table_name, {id, user_id, poll_id, option_id}) do
      true -> {:ok, %{vote | id: id}}
      false -> {:error, :bad_value}
    end
  end

  @spec update(%Vote{}) :: {:ok, %Vote{}} | {:error, :vote_not_found}
  def update(%Vote{id: id, user_id: user_id, poll_id: poll_id, option_id: option_id} = vote) do
    case get(id) do
      nil ->
        {:error, :vote_not_found}

      _vote ->
        :ets.insert(@table_name, {id, user_id, poll_id, option_id})
        {:ok, vote}
    end
  end

  @spec delete(%Vote{}) :: {:ok, %Vote{}} | {:error, :vote_not_found}
  def delete(%Vote{id: id} = vote) do
    case get(id) do
      nil ->
        {:error, :vote_not_found}

      _vote ->
        :ets.delete(@table_name, id)
        {:ok, vote}
    end
  end

  @spec get(id()) :: %Vote{} | nil
  def get(id) do
    @table_name |> :ets.lookup(id) |> format_response()
  end

  @spec list_by_user_id(user_id) :: [%Vote{}]
  def list_by_user_id(user_id) do
    @table_name |> :ets.match_object({:_, user_id, :_, :_}) |> Enum.map(&format_response/1)
  end

  ## ==========================================================================
  ## Private Functions
  ## ==========================================================================

  defp format_response([]), do: nil

  defp format_response([{id, user_id, poll_id, option_id}]) do
    format_response({id, user_id, poll_id, option_id})
  end

  defp format_response({id, user_id, poll_id, option_id}) do
    %Vote{id: id, user_id: user_id, poll_id: poll_id, option_id: option_id}
  end
end
