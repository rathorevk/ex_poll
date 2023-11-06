defmodule ExPoll.ETS.Polls.Options do
  @moduledoc """
  This module handles ets table options related operations/quaries.
  """

  alias ExPoll.Schema.Poll.Option

  ## ==========================================================================
  ## Types
  ## ==========================================================================

  @type id :: binary()
  @type user_id :: Users.id()
  @type poll_id :: Polls.id()

  @table_name :options

  ## ==========================================================================
  ## Public APIs
  ## ==========================================================================

  @spec new :: table_name when table_name: atom()
  def new do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  @spec insert(%Option{}) :: {:ok, %Option{}} | {:error, :bad_value}
  def insert(%Option{text: text, poll_id: poll_id}) do
    id = Ecto.UUID.generate()
    vote_count = 0

    case :ets.insert_new(@table_name, {id, text, poll_id, vote_count}) do
      true -> {:ok, get(id)}
      false -> {:error, :bad_value}
    end
  end

  @spec update(%Option{}) :: {:ok, %Option{}} | {:error, :option_not_found}
  def update(%Option{id: id, text: text, poll_id: poll_id, vote_count: vote_count} = option) do
    case get(id) do
      nil ->
        {:error, :option_not_found}

      _option ->
        :ets.insert(@table_name, {id, text, poll_id, vote_count})
        {:ok, option}
    end
  end

  @spec delete(%Option{}) :: {:ok, %Option{}} | {:error, :option_not_found}
  def delete(%Option{id: id} = option) do
    case get(id) do
      nil ->
        {:error, :option_not_found}

      _option ->
        :ets.delete(@table_name, id)
        {:ok, option}
    end
  end

  @spec add_vote(%Option{}) :: incremented_vote_count when incremented_vote_count: integer()
  def add_vote(%Option{id: id}) do
    @table_name |> :ets.update_counter(id, {4, 1})
  end

  @spec get(id()) :: %Option{} | nil
  def get(id) do
    @table_name |> :ets.lookup(id) |> format_response()
  end

  @spec get_by_poll_id(poll_id) :: [%Option{}]
  def get_by_poll_id(poll_id) do
    @table_name
    |> :ets.match_object({:_, :_, poll_id, :_})
    |> Enum.map(&format_response/1)
  end

  ## ==========================================================================
  ## Private Functions
  ## ==========================================================================

  defp format_response([]), do: nil

  defp format_response([{id, text, poll_id, vote_count}]) do
    format_response({id, text, poll_id, vote_count})
  end

  defp format_response({id, text, poll_id, vote_count}) do
    %Option{id: id, text: text, poll_id: poll_id, vote_count: vote_count}
  end
end
