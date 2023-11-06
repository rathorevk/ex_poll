defmodule ExPoll.UsersTest do
  use ExPoll.DataCase

  alias ExPoll.Users
  alias ExPoll.Schema.User

  @invalid_attrs %{username: nil}

  describe "create_user/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "with valid data creates a user" do
      valid_attrs = %{username: "test_username"}

      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.username == "test_username"
      refute is_nil(user.id)
    end

    test "with invalid data raise invalid changeset error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Users.create_user(@invalid_attrs)
      end
    end
  end

  describe "get_user/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "returns the user with given id" do
      user = create_user()
      assert Users.get_user(user.id) == user
    end

    test "returns nil when the user doesn't exist" do
      assert Users.get_user(Ecto.UUID.generate()) == nil
    end
  end

  describe "get_or_create_user/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "creates the user when user doesn't exist" do
      username = "username_2"
      assert {:ok, %User{} = user} = Users.get_or_create_user(%{"username" => username})
      assert user.username == username
      refute is_nil(user.id)
    end

    test "returns the user when user exist" do
      existing_user = create_user()

      assert {:ok, %User{} = user} =
               Users.get_or_create_user(%{"username" => existing_user.username})

      assert user.username == existing_user.username
      assert user.id == existing_user.id
    end
  end

  defp create_user do
    valid_attrs = %{username: "username_1"}
    {:ok, %User{} = user} = Users.create_user(valid_attrs)
    user
  end
end
