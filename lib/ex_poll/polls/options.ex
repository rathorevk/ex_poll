defmodule ExPoll.Polls.Options do
  @moduledoc """
  The Options context.
  """

  alias ExPoll.ETS.Polls.Options, as: OptionETS
  alias ExPoll.Polls
  alias ExPoll.Schema.Poll.Option
  alias ExPoll.Schema.Poll.Vote

  @doc """
  Creates options.

  ## Examples

      iex> create_option(["Option1", "Option2"])
      :ok

  """
  @spec create_options([String.t()], Polls.id()) :: :ok
  def create_options(options, poll_id) do
    Enum.each(options, fn text ->
      {:ok, _option} = create_option(%Option{}, %{text: text, poll_id: poll_id})
    end)
  end

  @doc """
  Creates a option.

  ## Examples

      iex> create_option(%{field: value})
      {:ok, %Option{}}

      iex> create_option(%{field: bad_value})
      {:error, :bad_value}

      iex> create_option(%{field: bad_value})
      ** (Ecto.InvalidChangesetError) could not perform update because changeset is invalid.

  """
  @spec create_option(%Option{}) :: {:ok, %Option{}} | {:error, :bad_value}
  def create_option(%Option{} = option, attrs \\ %{}) do
    option
    |> Option.changeset(attrs)
    |> Option.apply(:create)
    |> OptionETS.insert()
  end

  @doc """
  Updates a option.

  ## Examples

      iex> update_option(option, %{field: new_value})
      {:ok, %Option{}}

      iex> update_option(option, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

      iex> update_option(%{field: bad_value})
      ** (Ecto.InvalidChangesetError) could not perform update because changeset is invalid.

  """
  @spec update_option(%Option{}) :: {:ok, %Option{}}
  def update_option(%Option{} = option, attrs \\ %{}) do
    option
    |> Option.changeset(attrs)
    |> Option.apply(:update)
    |> OptionETS.update()
  end

  @doc """
  Updates vote_count in option.

  ## Examples

      iex> add_vote(option, %{field: new_value})
      :ok

      iex> add_vote(option, %{field: bad_value})
      {:error, :option_not_found}

  """
  @spec add_vote(%Option{}, map()) :: :ok | {:error, :option_not_found}
  def add_vote(%Option{id: id}, attrs) do
    case get_option(id) do
      nil ->
        {:error, :option_not_found}

      option ->
        {:ok, option} = OptionETS.add_vote(option)

        vote_attrs = %{option_id: option.id, poll_id: option.poll_id, user_id: attrs.user_id}
        {:ok, _vote} = Polls.Votes.create_vote(%Vote{}, vote_attrs)
        {:ok, option}
    end
  end

  @doc """
  Deletes a option.

  ## Examples

      iex> delete_option(option)
      true
  """
  @spec delete_option(%Option{}) :: true
  def delete_option(%Option{} = option) do
    OptionETS.delete(option)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking option changes.

  ## Examples

      iex> change_option(option)
      %Ecto.Changeset{data: %Option{}}

  """
  @spec change_option(%Option{}) :: Ecto.Changeset.t()
  def change_option(%Option{} = option, attrs \\ %{}) do
    Option.changeset(option, attrs)
  end

  @doc """
  Gets a single option.

  Returns nil if the Option does not exist.

  ## Examples

      iex> get_option("7575d819-fbe9-45b7-82f3-546c6db995a2")
      %Option{}

      iex> get_option("b575d819-fbe9-45b7-82f3-546c6db995c1")
      nil

  """
  @spec get_option(binary()) :: %Option{} | nil
  def get_option(id), do: OptionETS.get(id)
end
