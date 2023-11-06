defmodule ExPoll.PollsTest do
  use ExPoll.DataCase

  alias ExPoll.Users
  alias ExPoll.Polls
  alias ExPoll.Schema.Poll

  @invalid_attrs %{text: nil, creator_id: nil}

  setup_all do
    {:ok, user} = Users.create_user(%{username: "test_user"})

    {:ok, user_id: user.id}
  end

  describe "create_poll/2" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "with valid data creates a poll", %{user_id: user_id} do
      valid_attrs = %{text: "some text", creator_id: user_id}

      assert {:ok, %Poll{} = poll} = Polls.create_poll(%Poll{}, valid_attrs)
      assert poll.text == "some text"
      assert poll.creator_id == user_id
    end

    test "with invalid data raise invalid changeset error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Polls.create_poll(%Poll{}, @invalid_attrs)
      end
    end
  end

  describe "update_poll/2" do
    setup context do
      poll = create_poll(context.user_id)

      on_exit(fn -> cleanup_ets_tables() end)

      {:ok, poll: poll}
    end

    test "with valid data updates the poll", %{poll: poll} do
      update_attrs = %{text: "some updated text"}

      assert {:ok, %Poll{} = poll} = Polls.update_poll(poll, update_attrs)
      assert poll.text == "some updated text"
    end

    test "with invalid data raise invalid changeset error", %{poll: poll} do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Polls.update_poll(poll, @invalid_attrs)
      end
    end
  end

  describe "delete_poll/2" do
    test "deletes the poll", %{user_id: user_id} do
      valid_attrs = %{text: "some text", creator_id: user_id}

      {:ok, %Poll{} = poll} = Polls.create_poll(%Poll{}, valid_attrs)

      assert {:ok, poll} == Polls.delete_poll(poll)
      assert is_nil(Polls.get_poll(poll.id))
    end
  end

  describe "change_poll/2" do
    test "change_poll/2 returns a poll changeset", %{user_id: user_id} do
      valid_attrs = %{text: "some text", creator_id: user_id}
      assert %Ecto.Changeset{} = Polls.change_poll(%Poll{}, valid_attrs)
    end

    test "change_poll/2 with invalid data returns error changeset" do
      assert %Ecto.Changeset{
               errors: [
                 text: {"can't be blank", [validation: :required]},
                 creator_id: {"can't be blank", [validation: :required]}
               ]
             } = Polls.change_poll(%Poll{}, @invalid_attrs)
    end
  end

  describe "list_polls/0" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "returns all polls", %{user_id: user_id} do
      poll = create_poll(user_id)
      assert Polls.list_polls() == [poll]
    end
  end

  describe "get_poll/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "returns the poll with given id", %{user_id: user_id} do
      poll = create_poll(user_id)
      assert Polls.get_poll(poll.id) == poll
    end

    test "returns nil when the poll doesn't exist" do
      assert Polls.get_poll(Ecto.UUID.generate()) == nil
    end
  end

  defp create_poll(user_id) do
    valid_attrs = %{text: "some text", creator_id: user_id}
    {:ok, %Poll{} = poll} = Polls.create_poll(%Poll{}, valid_attrs)
    poll
  end
end
