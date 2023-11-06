defmodule ExPollWeb.PollLive.FormComponent do
  alias ExPollWeb.Live.Helper
  use ExPollWeb, :live_component

  alias ExPoll.Polls

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage poll records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="poll-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:text]} type="text" label="Poll Name" />
        <div id="options">
          <.input field={@form[:optionA]} type="text" label="Option-A" required />
          <.input field={@form[:optionB]} type="text" label="Option-B" required />
          <.input field={@form[:optionC]} type="text" label="Option-C" required />
          <.input field={@form[:optionD]} type="text" label="Option-D" required />
        </div>
        <:actions>
          <.button phx-disable-with="Saving...">Save Poll</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{poll: poll} = assigns, socket) do
    Logger.info("Update poll: #{inspect(poll)}")
    changeset = Polls.change_poll(poll)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"poll" => poll_params}, socket) do
    Logger.debug("Validate poll: #{inspect(poll_params)}")

    changeset =
      socket.assigns.poll
      |> Polls.change_poll(poll_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("vote", %{"poll_id" => poll_id}, socket) do
    Logger.debug("Submit vote: #{poll_id}")

    changeset =
      socket.assigns.poll
      |> Polls.change_poll(poll_id)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"poll" => poll_params}, socket) do
    save_poll(socket, socket.assigns.action, poll_params)
  end

  defp save_poll(socket, :edit, poll_params) do
    Logger.info("Edit poll: #{inspect(poll_params)}")

    case Polls.update_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        Logger.debug("Poll updated: #{inspect(poll)}")

        {:noreply,
         socket
         |> put_flash(:info, "Poll updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_poll(socket, :new, poll_params) do
    Logger.info("New poll: #{inspect(poll_params)}")

    {poll_params, options_params} = Map.split(poll_params, ["text"])
    options = Map.values(options_params)

    case Polls.create_poll(socket.assigns.poll, poll_params) do
      {:ok, poll} ->
        Polls.create_options(options, poll.id)

        :ok =
          Helper.pubsub_client().broadcast_polls_update({:poll_inserted, Polls.get_poll(poll.id)})

        Logger.debug("New poll created: #{inspect(poll)}")

        {:noreply,
         socket
         |> put_flash(:info, "Poll created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
