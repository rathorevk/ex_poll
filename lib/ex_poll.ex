defmodule ExPoll do
  @moduledoc """
  ExPoll keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  @pub_sub_topic "polls"
  # ===========================================================================
  def subscribe_to_polls_updates() do
    Phoenix.PubSub.subscribe(ExPoll.PubSub, @pub_sub_topic)
  end

  # ===========================================================================
  def broadcast_polls_update(msg) do
    Phoenix.PubSub.broadcast(
      ExPoll.PubSub,
      @pub_sub_topic,
      msg
    )
  end
end
