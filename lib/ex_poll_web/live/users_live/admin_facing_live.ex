defmodule ExPollWeb.AdminFacingLive do
  use ExPollWeb, :live_view

  def render(assigns) do
    ~H"""
    <h1>Hello Admin, welcome back.</h1>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
