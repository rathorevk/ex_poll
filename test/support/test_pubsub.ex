defmodule ExPoll.TestPubSub do
  @moduledoc false

  @spec subscribe_to_polls_updates() :: :ok
  def subscribe_to_polls_updates, do: :ok

  @spec broadcast_polls_update(any()) :: :ok
  def broadcast_polls_update(_msg), do: :ok
end
