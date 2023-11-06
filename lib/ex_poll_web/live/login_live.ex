defmodule ExPollWeb.LoginLive do
  use ExPollWeb, :live_view

  alias ExPollWeb.ETS.UserAuth
  alias ExPollWeb.Live.Helper

  alias ExPoll.Schema.User
  alias ExPoll.Users

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Create and Vote Polls
      </.header>

      <.simple_form for={@form} id="login_form" phx-change="validate" phx-submit="login">
        <.input field={@form[:username]} label="Username" required />
        <:actions>
          <.button phx-disable-with="Joining in..." class="w-full">
            Join <span aria-hidden="true">→</span>
          </.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def mount(_params, %{"user_id" => user_id} = _session, socket) do
    Logger.info("Existing user session: #{user_id}")
    {:ok, push_redirect(socket, to: "/polls", replace: true)}
  end

  def mount(_params, %{"session_uuid" => session_uuid} = session, socket) do
    Logger.info("Login session: #{inspect(session)}")

    username = live_flash(socket.assigns.flash, :username)
    form = to_form(%{"username" => username}, as: :user)

    {:ok,
     assign(socket,
       session_uuid: session_uuid,
       form: form,
       current_user: %User{}
     )}
  end

  @impl true
  def handle_event("save", %{"user" => params}, socket) do
    if Map.get(params, "form_disabled", nil) != "true" do
      changeset =
        User.changeset(%User{}, params)
        |> Ecto.Changeset.put_change(:form_submitted, true)
        |> Ecto.Changeset.put_change(:form_disabled, true)
        |> Map.put(:action, :insert)

      send(self(), {:disable_form, changeset})

      {:noreply, assign(socket, changeset: changeset)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("login", %{"user" => user_params} = _params, socket) do
    Logger.info("Recieved login event: #{inspect(user_params)}")

    case Users.get_or_create_user(user_params) do
      {:ok, user} ->
        Logger.info("User created successfully: #{inspect(user)}")
        insert_session_token(socket.assigns.session_uuid, user.id)

        {:noreply,
         socket
         |> put_flash(:info, "User joined successfully")
         |> push_navigate(to: ~p"/polls/")}

      {:error, %Ecto.Changeset{} = changeset} ->
        Logger.warning("Error in user login: #{inspect(changeset)}")

        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    changeset = User.changeset(%User{}, params) |> Map.put(:action, :insert)
    {:noreply, assign(socket, changeset: changeset)}
  end

  @impl true
  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      socket.assigns.current_user
      |> Users.change_user(user_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  defp insert_session_token(key, user_id) do
    salt = Helper.signing_salt()
    token = Phoenix.Token.sign(ExPollWeb.Endpoint, salt, user_id)
    UserAuth.insert(key, token)
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end
end
