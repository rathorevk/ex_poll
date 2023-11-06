defmodule ExPoll.Polls do
  @moduledoc """
  The Polls context.
  """

  alias ExPoll.ETS.Polls, as: PollETS
  alias ExPoll.Polls.Options
  alias ExPoll.Polls.Votes
  alias ExPoll.Schema.Poll

  defdelegate create_options(options_attrs, poll_id), to: Options
  defdelegate add_vote(option, attrs), to: Options
  defdelegate list_vote_by_user_id(user_id), to: Votes, as: :list_by_user_id

  @doc """
  Creates a poll.

  ## Examples

      iex> create_poll(%{field: value})
      {:ok, %Poll{}}

      iex> create_poll(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_poll(%Poll{} = poll, poll_params) do
    {:ok, poll} =
      poll
      |> Poll.changeset(poll_params)
      |> Poll.apply(:create)
      |> PollETS.insert()

    {:ok, poll}
  end

  @doc """
  Updates a poll.

  ## Examples

      iex> update_poll(poll, %{field: new_value})
      {:ok, %Poll{}}

  """
  def update_poll(%Poll{} = poll, attrs) do
    poll
    |> Poll.changeset(attrs)
    |> Poll.apply(:update)
    |> PollETS.update()
  end

  @doc """
  Deletes a poll.

  ## Examples

      iex> delete_poll(poll)
      {:ok, %Poll{}}

      iex> delete_poll(poll)
      {:error, %Ecto.Changeset{}}

  """
  def delete_poll(%Poll{} = poll) do
    poll
    |> Poll.changeset()
    |> Poll.apply(:delete)
    |> PollETS.delete()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking poll changes.

  ## Examples

      iex> change_poll(poll)
      %Ecto.Changeset{data: %Poll{}}

  """
  def change_poll(%Poll{} = poll, attrs \\ %{}) do
    Poll.changeset(poll, attrs)
  end

  @doc """
  Gets a single poll.

  Raises `Ecto.NoResultsError` if the Poll does not exist.

  ## Examples

      iex> get_poll("7575d819-fbe9-45b7-82f3-546c6db995a2")
      %Poll{}

      iex> get_poll("b575d819-fbe9-45b7-82f3-546c6db99562")
      nil

  """
  def get_poll(id), do: PollETS.get(id)

  @doc """
  Returns the list of polls.

  ## Examples

      iex> list_polls()
      [%Poll{}, ...]

  """
  def list_polls do
    PollETS.all()
  end
end
