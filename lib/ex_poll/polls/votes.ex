defmodule ExPoll.Polls.Votes do
  @moduledoc """
  The Votes context.
  """

  alias ExPoll.ETS.Polls.Votes, as: VoteETS
  alias ExPoll.Schema.Poll.Vote

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(%{field: value})
      {:ok, %Vote{}}

      iex> create_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(%Vote{} = vote, attrs \\ %{}) do
    vote
    |> Vote.changeset(attrs)
    |> Vote.apply(:create)
    |> VoteETS.insert()
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Vote{} = vote, attrs) do
    vote
    |> Vote.changeset(attrs)
    |> Vote.apply(:update)
    |> VoteETS.update()
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(vote)
      {:ok, %Vote{}}

      iex> delete_vote(vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Vote{} = vote) do
    VoteETS.delete(vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Vote{} = vote, attrs \\ %{}) do
    Vote.changeset(vote, attrs)
  end

  @doc """
  Returns list of votes.

  ## Examples

      iex> list_by_user_id(user_id)
      [%Vote{}]

  """
  def list_by_user_id(user_id) do
    VoteETS.list_by_user_id(user_id)
  end
end
