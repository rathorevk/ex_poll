defmodule ExPollWeb.Live.Helper do
  @pubsub_client Application.compile_env(:ex_poll, :pubsub_client)

  def signing_salt do
    ExPollWeb.Endpoint.config(:live_view)[:signing_salt] ||
      raise "missing signing_salt"
  end

  def pubsub_client do
    @pubsub_client
  end
end
