defmodule ExPoll.OptionTest do
  use ExPoll.DataCase

  alias ExPoll.Users
  alias ExPoll.Polls
  alias ExPoll.Polls.Options
  alias ExPoll.Schema.Poll
  alias ExPoll.Schema.Poll.Option

  @invalid_attrs %{text: nil, poll_id: nil, vote_count: nil}

  setup_all do
    {:ok, user} = Users.create_user(%{username: "test_user"})
    {:ok, %Poll{} = poll} = Polls.create_poll(%Poll{}, %{text: "Test Poll", creator_id: user.id})

    {:ok, poll_id: poll.id, user_id: user.id}
  end

  describe "create_option/2" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "with valid data creates a option", %{poll_id: poll_id} do
      valid_attrs = %{text: "OptionA", poll_id: poll_id}
      assert {:ok, %Option{} = option} = Options.create_option(%Option{}, valid_attrs)

      assert option.text == "OptionA"
      assert option.poll_id == poll_id
      assert option.vote_count == 0
    end

    test "with invalid data raise invalid changeset error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Options.create_option(%Option{}, @invalid_attrs)
      end
    end
  end

  describe "add_vote/2" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "with valid data increase vote_count by 1", %{poll_id: poll_id, user_id: user_id} do
      option = create_option(poll_id)

      assert {:ok, %Option{} = updated_option} = Options.add_vote(option, %{user_id: user_id})

      assert updated_option.id == option.id
      assert updated_option.text == option.text
      assert updated_option.poll_id == option.poll_id
      assert updated_option.vote_count == 1
    end
  end

  describe "get_option/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "returns the option with given id", %{poll_id: poll_id} do
      option = create_option(poll_id)
      assert Options.get_option(option.id) == option
    end

    test "returns nil when the option doesn't exist" do
      assert Options.get_option(Ecto.UUID.generate()) == nil
    end
  end

  defp create_option(poll_id) do
    valid_attrs = %{text: "some text", poll_id: poll_id}
    {:ok, %Option{} = option} = Options.create_option(%Option{}, valid_attrs)
    option
  end
end
