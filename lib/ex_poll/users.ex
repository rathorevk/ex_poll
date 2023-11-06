defmodule ExPoll.Users do
  @moduledoc """
  The Users context.
  """

  alias ExPoll.ETS.Users, as: UserETS
  alias ExPoll.Schema.User

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      ** (Ecto.InvalidChangesetError) could not perform update because changeset is invalid.

  """
  def create_user(attrs) do
    %User{}
    |> User.changeset(attrs)
    |> User.apply(:create)
    |> UserETS.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(%{field: value})
      {:ok, %User{}}

      iex> update_user(%{field: bad_value})
      ** (Ecto.InvalidChangesetError) could not perform update because changeset is invalid.

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> User.apply(:update)
    |> UserETS.update()
  end

  @doc """
  Gets a single user.

  ## Examples

      iex> get_user("7575d819-fbe9-45b7-82f3-546c6db995a2")
      %User{}

      iex> get_user("b575d819-fbe9-45b7-82f3-546c6db99562")
      nil

  """
  def get_user(id), do: UserETS.get(id)

  @doc """
  Gets a user by username if not found then creates user.

  ## Examples

      iex> get_or_create_user("username1")
      {:ok, %User{}}

      iex> get_or_create_user("username2")
      nil

  """
  def get_or_create_user(attrs) do
    case get_user_by_username(attrs["username"]) do
      nil -> create_user(attrs)
      user -> update_user(user, attrs)
    end
  end

  @doc """
  Gets a user by username.

  ## Examples

      iex> get_user_by_username("username1")
      %User{}

      iex> get_user_by_username("username2")
      nil

  """
  def get_user_by_username(username) when is_binary(username) do
    UserETS.get_by_username(username)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(polls)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%Poll{}, ...]

  """
  def list_users do
    UserETS.all()
  end
end
