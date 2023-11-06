defmodule ExPollWeb.LogoutController do
  use ExPollWeb, :controller

  import Plug.Conn, only: [get_session: 2, clear_session: 1, configure_session: 2]

  alias ExPollWeb.ETS.UserAuth

  def index(conn, _params \\ %{}) do
    conn
    |> delete_session_token(get_session(conn, :session_uuid))
    |> clear_session()
    |> configure_session(drop: true)
    |> redirect(to: "/login")
  end

  defp delete_session_token(conn, nil), do: conn

  defp delete_session_token(conn, session_id) do
    UserAuth.delete_session(session_id)
    conn
  end
end
