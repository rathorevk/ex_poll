defmodule ExPoll.PubSub do
  @moduledoc """
  The Polls PubSub context module.
  """

  @pub_sub_topic "polls"
  # ===========================================================================
  @spec subscribe_to_polls_updates() :: :ok | {:error, {:already_registered, pid()}}
  def subscribe_to_polls_updates() do
    Phoenix.PubSub.subscribe(ExPoll.PubSub, @pub_sub_topic)
  end

  # ===========================================================================
  @spec broadcast_polls_update(any()) :: :ok | {:error, any()}
  def broadcast_polls_update(msg) do
    Phoenix.PubSub.broadcast(
      ExPoll.PubSub,
      @pub_sub_topic,
      msg
    )
  end
end
