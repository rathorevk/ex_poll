defmodule ExPoll.ETS.Polls do
  @moduledoc """
  This module handles ets table polls related operations/quaries.
  """

  alias ExPoll.ETS.Polls.Options
  alias ExPoll.ETS.Users
  alias ExPoll.Schema.Poll

  ## ==========================================================================
  ## Types
  ## ==========================================================================
  @type id :: binary()
  @type creator_id :: Users.id()

  @table_name :polls

  ## ==========================================================================
  ## Public APIs
  ## ==========================================================================
  @spec new :: table_name when table_name: atom()
  def new do
    :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])
  end

  @spec insert(%Poll{}) :: {:ok, %Poll{}} | {:error, :bad_value}
  def insert(%Poll{text: text, creator_id: creator_id}) do
    id = Ecto.UUID.generate()
    options = []

    case :ets.insert_new(@table_name, {id, text, creator_id, options}) do
      true -> {:ok, get(id)}
      false -> {:error, :bad_value}
    end
  end

  @spec update(%Poll{}) :: {:ok, %Poll{}} | {:error, :poll_not_found}
  def update(%Poll{id: id, text: text, creator_id: creator_id} = poll) do
    case get(id) do
      nil ->
        {:error, :poll_not_found}

      _poll ->
        :ets.insert(@table_name, {id, text, creator_id, []})
        {:ok, poll}
    end
  end

  @spec delete(%Poll{}) :: {:ok, %Poll{}} | {:error, :poll_not_found}
  def delete(%Poll{id: id} = poll) do
    case get(id) do
      nil ->
        {:error, :poll_not_found}

      _poll ->
        :ets.delete(@table_name, id)
        {:ok, poll}
    end
  end

  @spec get(id()) :: %Poll{} | nil
  def get(id) do
    @table_name |> :ets.lookup(id) |> format_response()
  end

  @spec all() :: [%Poll{}]
  def all do
    @table_name
    |> :ets.match(:"$1")
    |> Enum.map(&format_response/1)
  end

  ## ==========================================================================
  ## Private Functions
  ## ==========================================================================

  defp format_response([]), do: nil

  defp format_response([{id, text, creator_id, options}]) do
    format_response({id, text, creator_id, options})
  end

  defp format_response({id, text, creator_id, _options}) do
    options = Options.get_by_poll_id(id)
    %Poll{id: id, text: text, creator_id: creator_id, options: options}
  end
end
