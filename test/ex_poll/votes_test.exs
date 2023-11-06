defmodule ExPoll.VotesTest do
  use ExPoll.DataCase

  alias ExPoll.Users
  alias ExPoll.Polls
  alias ExPoll.Polls.Options
  alias ExPoll.Polls.Votes
  alias ExPoll.Schema.Poll
  alias ExPoll.Schema.Poll.Option
  alias ExPoll.Schema.Poll.Vote

  @invalid_attrs %{user_id: nil, poll_id: nil, option_id: nil}

  setup_all do
    {:ok, user} = Users.create_user(%{username: "test_user"})
    {:ok, %Poll{} = poll} = Polls.create_poll(%Poll{}, %{text: "Test Poll", creator_id: user.id})

    {:ok, %Option{} = option} =
      Options.create_option(%Option{}, %{text: "Test Option", poll_id: poll.id})

    {:ok, option_id: option.id, poll: poll}
  end

  describe "create_vote/2" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "with valid data creates a vote", %{option_id: option_id, poll: poll} do
      valid_attrs = %{option_id: option_id, poll_id: poll.id, user_id: poll.creator_id}
      assert {:ok, %Vote{} = vote} = Votes.create_vote(%Vote{}, valid_attrs)

      assert vote.option_id == option_id
      assert vote.poll_id == poll.id
      assert vote.user_id == poll.creator_id
    end

    test "with invalid data raise invalid changeset error" do
      assert_raise Ecto.InvalidChangesetError, fn ->
        Votes.create_vote(%Vote{}, @invalid_attrs)
      end
    end
  end

  describe "list_vote_by_user_id/1" do
    setup do
      on_exit(fn -> cleanup_ets_tables() end)

      :ok
    end

    test "returns the list of votes", %{option_id: option_id, poll: poll} do
      valid_attrs = %{option_id: option_id, poll_id: poll.id, user_id: poll.creator_id}
      assert {:ok, %Vote{} = vote} = Votes.create_vote(%Vote{}, valid_attrs)

      assert Votes.list_by_user_id(poll.creator_id) == [vote]
    end
  end
end
