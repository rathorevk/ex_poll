defmodule ExPollWeb.LiveAuth do
  use ExPollWeb, :live_view

  alias ExPoll.Users
  alias ExPoll.Schema.User

  alias ExPollWeb.ETS.UserAuth
  alias ExPollWeb.Live.Helper

  require Logger

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <%= if @current_user do %>
        <p>Welcome, <%= @current_user.username %></p>
        <a phx-click="logout">Logout</a>
      <% else %>
        <p>You are not logged in.</p>
        <a phx-click="login">Login</a>
      <% end %>
    </div>
    """
  end

  def on_mount(:require_authenticated_user, _, session, socket) do
    socket = assign_current_user(socket, session)

    Logger.info("Authenticate user: #{inspect(socket.assigns.current_user)}")

    case socket.assigns.current_user do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "You have to Sign in to continue")
         |> redirect(to: ~p"/login")}

      %User{} ->
        {:cont, socket}
    end
  end

  defp assign_current_user(socket, session) do
    Logger.info("Auth session_uuid: #{session["session_uuid"]}")

    case session["session_uuid"] do
      nil ->
        socket |> assign_new(:user_id, fn -> nil end) |> assign_new(:current_user, fn -> nil end)

      session_uuid ->
        case get_user_id(session_uuid) do
          nil ->
            socket
            |> assign_new(:user_id, fn -> nil end)
            |> assign_new(:current_user, fn -> nil end)

          user_id ->
            user = Users.get_user(user_id)
            Logger.debug("Auth user: #{inspect(user)}")

            socket
            |> assign_new(:user_id, fn -> user_id end)
            |> assign_new(:current_user, fn -> user end)
        end
    end
  end

  defp get_user_id(session_uuid) do
    case UserAuth.lookup(session_uuid) do
      [{_, token}] ->
        case Phoenix.Token.verify(ExPollWeb.Endpoint, Helper.signing_salt(), token,
               max_age: 806_400
             ) do
          {:ok, user_id} -> user_id
          _ -> nil
        end

      _ ->
        nil
    end
  end
end
