defmodule ExPollWeb.PollLive.Index do
  use ExPollWeb, :live_view

  alias ExPoll.Polls
  alias ExPoll.Schema.Poll
  alias ExPollWeb.Live.Helper

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    Logger.info("Init polls user_id: #{socket.assigns[:user_id]}")

    case socket.assigns[:user_id] do
      nil ->
        {:ok,
         socket
         |> push_navigate(to: ~p"/login")}

      user_id ->
        if connected?(socket), do: Helper.pubsub_client().subscribe_to_polls_updates()

        polls = Polls.list_polls()

        polls_voted =
          user_id
          |> Polls.list_vote_by_user_id()
          |> Enum.map(& &1.poll_id)

        Logger.debug("intialize polls: #{inspect(polls)}, polls_voted: #{inspect(polls_voted)}")

        {:ok,
         assign(socket, user_id: user_id, polls: polls, polls_voted: MapSet.new(polls_voted))}
    end
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"poll_id" => id}) do
    socket
    |> assign(:page_title, "Edit Poll")
    |> assign(:poll, Polls.get_poll(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Poll")
    |> assign(:poll, %Poll{creator_id: socket.assigns.user_id})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Polls")
    |> assign(:poll, nil)
  end

  defp apply_action(socket, :vote, params) do
    Logger.info("Recieved submit_vote event params: #{inspect(params)}")
    [poll_id, option_id] = String.split(hd(Map.values(params)), "||")
    user_id = socket.assigns.user_id

    {:ok, option} = Polls.add_vote(%Poll.Option{id: option_id}, %{user_id: user_id})

    updated_poll = Polls.get_poll(option.poll_id)
    :ok = Helper.pubsub_client().broadcast_polls_update({:poll_updated, updated_poll})

    updated_polls = update_polls(socket.assigns.polls, updated_poll)

    {:noreply,
     assign(socket,
       polls: updated_polls,
       polls_voted: MapSet.put(socket.assigns.polls_voted, poll_id)
     )}
  end

  @impl true
  def handle_info({:poll_inserted, new_poll}, socket) do
    Logger.debug("New Poll inserted: #{inspect(new_poll)}")

    {:noreply, socket |> assign(:polls, [new_poll | socket.assigns.polls])}
  end

  def handle_info({:poll_updated, updated_poll}, socket) do
    Logger.debug("Poll updated: #{inspect(updated_poll)}")

    updated_polls = update_polls(socket.assigns.polls, updated_poll)

    {:noreply, socket |> assign(polls: updated_polls)}
  end

  def handle_info({:poll_deleted, deleted_poll}, socket) do
    Logger.debug("Poll deleted: #{inspect(deleted_poll)}")

    updated_polls = delete_polls(socket.assigns.polls, deleted_poll)

    {:noreply, socket |> assign(polls: updated_polls)}
  end

  @impl true
  def handle_event("vote", %{"poll_id" => poll_id, "option_id" => option_id}, socket) do
    Logger.info("Recieved submit_vote event poll_id #{poll_id}, option_id #{option_id}")
    user_id = socket.assigns.user_id

    {:ok, option} = Polls.add_vote(%Poll.Option{id: option_id}, %{user_id: user_id})

    updated_poll = Polls.get_poll(option.poll_id)
    :ok = Helper.pubsub_client().broadcast_polls_update({:poll_updated, updated_poll})

    updated_polls = update_polls(socket.assigns.polls, updated_poll)

    {:noreply,
     assign(socket,
       polls: updated_polls,
       polls_voted: MapSet.put(socket.assigns.polls_voted, poll_id)
     )}
  end

  def handle_event("delete", %{"poll_id" => id}, socket) do
    poll = Polls.get_poll(id)
    {:ok, _} = Polls.delete_poll(poll)

    {:noreply, socket}
  end

  defp update_polls(polls, updated_poll) do
    Enum.map(polls, fn poll ->
      if poll.id == updated_poll.id,
        do: updated_poll,
        else: poll
    end)
  end

  defp delete_polls(polls, delete_poll) do
    Enum.reduce(polls, [], fn poll, acc ->
      if poll.id == delete_poll.id,
        do: acc,
        else: [poll | acc]
    end)
  end

  defp calculate_percentage(option, options) do
    total_vote_count = total_vote_count(options)
    float = Float.round(100 * option.vote_count / total_vote_count, 2)
    truncated = trunc(float)
    if truncated == float, do: truncated, else: float
  end

  defp total_vote_count(options) do
    options |> Enum.reduce(0, fn op, acc -> acc + op.vote_count end)
  end

  defp with_option_title(options) do
    options |> Enum.zip(["A", "B", "C", "D"])
  end
end
